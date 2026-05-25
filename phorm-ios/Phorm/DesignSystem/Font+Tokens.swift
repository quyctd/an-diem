import SwiftUI
import UIKit

/// Hà Nội cũ typography — Vietnamese vernacular print register.
/// See DESIGN.md and themes-preview.html for the canonical visual.
///
/// Long-term: the app should bundle Noto Serif Display, Cormorant Garamond,
/// IBM Plex Serif, and Spectral as in-app fonts (register via Info.plist
/// `UIAppFonts` + ship the .ttf files). Until those are bundled, the tokens
/// fall back to `.system(_, design: .serif)` — SwiftUI resolves this to a
/// platform serif (typically New York on iOS), which is closer to the target
/// than SF Pro / SF Mono and gives full Vietnamese diacritic coverage. SF Mono
/// is forbidden anywhere in the app.
extension Font {
    // MARK: - Editorial — display tier (Noto Serif Display target, serif fallback)
    /// Hero — end-of-session champion name, empty-state title. 32pt / weight 800.
    static let phormHeroDisplay  = Font.scaledSerif(40, weight: .heavy, relativeTo: .largeTitle)
    /// Largest display — session titles, summary header. 32pt / 800.
    static let phormDisplayLg    = Font.scaledSerif(32, weight: .heavy, relativeTo: .largeTitle)
    /// Standalone modal titles, end-of-session subtitle. 28pt / 700.
    static let phormDisplayMd    = Font.system(size: 28, weight: .bold, design: .serif)
    /// Session header in nav bar. 22pt / 700.
    static let phormTitleLg      = Font.system(size: 22, weight: .bold, design: .serif)
    /// Sheet headers, section dividers. 20pt / 700.
    static let phormTitleMd      = Font.system(size: 20, weight: .bold, design: .serif)
    /// Default nav title, player names in round-entry rows. 17pt / 600.
    static let phormTitleSm      = Font.system(size: 17, weight: .semibold, design: .serif)

    // MARK: - Editorial — body tier (Spectral target, serif fallback)
    /// Body copy, button labels. 15pt / 400.
    static let phormBodyMd       = Font.system(size: 15, weight: .regular, design: .serif)
    /// Secondary meta, player lists in history rows. 13pt / 400.
    static let phormBodySm       = Font.system(size: 13, weight: .regular, design: .serif)
    /// Round-card "Ván N" label, time meta. 12pt / 500.
    static let phormCaption      = Font.system(size: 12, weight: .medium, design: .serif)
    /// Section labels — "PHIÊN ĐANG CHƠI", "VÒNG", "TỔNG". 9pt uppercase, letter-spaced via .tracking.
    static let phormCaptionSection = Font.scaledSerif(9, weight: .semibold, relativeTo: .caption2)
    /// Primary CTA label. 14pt / 600 uppercase — letter-spacing applied via .tracking at use site.
    static let phormButton       = Font.system(size: 14, weight: .semibold, design: .serif)

    // MARK: - Italic — player names (Cormorant Garamond italic target)
    /// Player display name — italic serif gives "signature" feel. 22pt / 600 italic.
    static let phormNameDisplay  = Font.system(size: 22, weight: .semibold, design: .serif).italic()
    /// Player name in round-entry rows. 18pt / 600 italic.
    static let phormNameMd       = Font.system(size: 18, weight: .semibold, design: .serif).italic()

    // MARK: - Numerals (IBM Plex Serif tabular target; serif + monospacedDigit fallback)
    /// Champion +24 on end-of-session — biggest number on screen. 44pt / 800.
    static let phormNumberHero    = Font.system(size: 44, weight: .heavy, design: .serif).monospacedDigit()
    /// Leaderboard totals, ranking values. 26pt / 800.
    static let phormNumberRanking = Font.system(size: 26, weight: .heavy, design: .serif).monospacedDigit()
    /// Round-entry value inputs. 22pt / 700.
    static let phormNumberEntry   = Font.system(size: 22, weight: .bold, design: .serif).monospacedDigit()
    /// Round-card inline scores. 17pt / 600.
    static let phormNumberMd      = Font.system(size: 17, weight: .semibold, design: .serif).monospacedDigit()
    /// Round history strip, dense meta. 15pt / 500.
    static let phormNumberSm      = Font.system(size: 15, weight: .medium, design: .serif).monospacedDigit()
    /// Score chip running total. 17pt / 700.
    static let phormNumberChip    = Font.system(size: 17, weight: .bold, design: .serif).monospacedDigit()
    /// Auto-fill computed value — italic distinguishes "machine wrote this" from "host wrote this".
    static let phormNumberScript  = Font.system(size: 22, weight: .medium, design: .serif).italic().monospacedDigit()

    // MARK: - Keypad
    /// Custom keypad digits 0-9 on RoundEntryView. 26pt / 500 — slightly heavier than system keyboard.
    static let phormKeypadDigit  = Font.system(size: 26, weight: .medium, design: .serif).monospacedDigit()

    // MARK: - Helpers
    fileprivate static func scaledSerif(
        _ size: CGFloat,
        weight: UIFont.Weight,
        relativeTo style: UIFont.TextStyle
    ) -> Font {
        let descriptor = UIFont.systemFont(ofSize: size, weight: weight).fontDescriptor
            .withDesign(.serif) ?? UIFont.systemFont(ofSize: size, weight: weight).fontDescriptor
        let base = UIFont(descriptor: descriptor, size: size)
        return Font(UIFontMetrics(forTextStyle: style).scaledFont(for: base))
    }
}
