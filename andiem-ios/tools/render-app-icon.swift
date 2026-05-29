#!/usr/bin/env swift
// Renders the Phorm app icon (1024×1024) from the same SwiftUI primitives the
// EmptyHomeView "壹 seal on cinnabar" logo uses. Run from the repo root:
//
//     swift andiem-ios/tools/render-app-icon.swift
//
// Writes Phorm/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png
// and rewrites the appiconset's Contents.json to reference it.
//
// Requires macOS 13+ (SwiftUI ImageRenderer). Deterministic — re-running
// produces a bit-identical PNG for the same source.

import SwiftUI
import AppKit
import CoreGraphics

// MARK: - Tokens (mirror DESIGN.md / Color+Tokens.swift)
let cinnabar       = Color(red: 0x8C/255, green: 0x2A/255, blue: 0x22/255)
let cinnabarDeep   = Color(red: 0x5A/255, green: 0x16/255, blue: 0x12/255)
let gold           = Color(red: 0xD9/255, green: 0xB2/255, blue: 0x5A/255)
let goldDim        = Color(red: 0xA8/255, green: 0x84/255, blue: 0x38/255)
let cream          = Color(red: 0xF3/255, green: 0xE8/255, blue: 0xD2/255)

// MARK: - Halftone + grain (precomputed once)

func halftoneTile() -> NSImage {
    let size = NSSize(width: 16, height: 16)
    let img = NSImage(size: size)
    img.lockFocus()
    NSColor.clear.setFill()
    NSRect(origin: .zero, size: size).fill()
    NSColor(red: 0.95, green: 0.91, blue: 0.82, alpha: 0.10).setFill()
    NSBezierPath(ovalIn: NSRect(x: 0, y: 0, width: 2, height: 2)).fill()
    img.unlockFocus()
    return img
}

func grainTile(seed: UInt64 = 0xC0FFEE) -> NSImage {
    let size = NSSize(width: 400, height: 400)
    let img = NSImage(size: size)
    img.lockFocus()
    NSColor.clear.setFill()
    NSRect(origin: .zero, size: size).fill()
    var state = seed
    @inline(__always) func nextUnit() -> Double {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return Double(state & 0xFFFFFF) / Double(0xFFFFFF)
    }
    for _ in 0..<22_000 {
        let x = CGFloat(nextUnit()) * size.width
        let y = CGFloat(nextUnit()) * size.height
        let dark = nextUnit() < 0.55
        let alpha = CGFloat(nextUnit()) * 0.20 + 0.05
        let color = dark
            ? NSColor(white: 0.05, alpha: alpha)
            : NSColor(red: 0.95, green: 0.92, blue: 0.85, alpha: alpha * 0.6)
        color.setFill()
        NSBezierPath(ovalIn: NSRect(x: x, y: y, width: 1.4, height: 1.4)).fill()
    }
    img.unlockFocus()
    return img
}

// MARK: - Icon view

struct AppIconView: View {
    let halftone: NSImage
    let grain: NSImage

    var body: some View {
        ZStack {
            // Base cinnabar
            cinnabar

            // Warm vignette — center brightens, corners deepen
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.86, blue: 0.70).opacity(0.16),
                    .clear,
                    Color.black.opacity(0.28)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Halftone dots
            Image(nsImage: halftone)
                .resizable(resizingMode: .tile)
                .blendMode(.screen)

            // Paper grain
            Image(nsImage: grain)
                .resizable(resizingMode: .tile)
                .blendMode(.overlay)
                .opacity(0.62)

            // The seal — gold-filled rounded square + cinnabar-deep 壹, rotated −3°
            ZStack {
                // Glow halo
                RoundedRectangle(cornerRadius: 72, style: .continuous)
                    .fill(gold.opacity(0.32))
                    .frame(width: 720, height: 720)
                    .blur(radius: 48)

                // Seal body
                RoundedRectangle(cornerRadius: 56, style: .continuous)
                    .fill(gold)
                    .frame(width: 620, height: 620)
                    .overlay(
                        RoundedRectangle(cornerRadius: 56, style: .continuous)
                            .stroke(goldDim, lineWidth: 6)
                    )
                    .shadow(color: .black.opacity(0.32), radius: 18, x: 0, y: 10)

                // Inner gold gradient (subtle leaf shimmer)
                RoundedRectangle(cornerRadius: 48, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [cream.opacity(0.45), .clear, .black.opacity(0.18)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 4
                    )
                    .frame(width: 600, height: 600)

                // The character
                Text("壹")
                    .font(.system(size: 420, weight: .heavy, design: .serif))
                    .foregroundStyle(cinnabarDeep)
                    .offset(y: -8)
            }
            .rotationEffect(.degrees(-3))
        }
        .frame(width: 1024, height: 1024)
        .clipped()
    }
}

// MARK: - Render + write (MainActor — ImageRenderer requires it)

@MainActor
func render() throws {
    let halftone = halftoneTile()
    let grain = grainTile()

    let view = AppIconView(halftone: halftone, grain: grain)
    let renderer = ImageRenderer(content: view)
    renderer.scale = 1.0
    renderer.proposedSize = ProposedViewSize(width: 1024, height: 1024)

    guard let cg = renderer.cgImage else {
        fputs("ImageRenderer.cgImage returned nil\n", stderr)
        exit(1)
    }

    let rep = NSBitmapImageRep(cgImage: cg)
    guard let pngData = rep.representation(using: .png, properties: [:]) else {
        fputs("PNG encode failed\n", stderr)
        exit(1)
    }

    let scriptURL = URL(fileURLWithPath: CommandLine.arguments[0]).resolvingSymlinksInPath()
    let projectRoot = scriptURL
        .deletingLastPathComponent()  // tools/
        .deletingLastPathComponent()  // andiem-ios/
        .deletingLastPathComponent()  // repo root
    let outDir = projectRoot
        .appendingPathComponent("andiem-ios/Phorm/Resources/Assets.xcassets/AppIcon.appiconset", isDirectory: true)
    let outPng = outDir.appendingPathComponent("AppIcon-1024.png")
    let outJson = outDir.appendingPathComponent("Contents.json")

    try pngData.write(to: outPng)
    print("wrote \(outPng.path) (\(pngData.count) bytes)")

    let contentsJson = """
    {
      "images" : [
        {
          "filename" : "AppIcon-1024.png",
          "idiom" : "universal",
          "platform" : "ios",
          "size" : "1024x1024"
        }
      ],
      "info" : {
        "author" : "xcode",
        "version" : 1
      }
    }
    """
    try contentsJson.write(to: outJson, atomically: true, encoding: .utf8)
    print("wrote \(outJson.path)")
}

Task { @MainActor in
    do {
        try render()
        exit(0)
    } catch {
        fputs("render failed: \(error)\n", stderr)
        exit(1)
    }
}

RunLoop.main.run()
