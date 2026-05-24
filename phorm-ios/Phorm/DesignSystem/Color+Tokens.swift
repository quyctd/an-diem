import SwiftUI

extension Color {
    // MARK: - Brand (identical in both modes)
    static let phormPrimary         = Color(red: 0xFC/255, green: 0xD5/255, blue: 0x35/255)   // #FCD535
    static let phormPrimaryActive   = Color(red: 0xF0/255, green: 0xB9/255, blue: 0x0B/255)   // #F0B90B
    static let phormPrimaryDisabled = Color(red: 0x3A/255, green: 0x3A/255, blue: 0x1F/255)   // #3A3A1F
    static let onPrimary            = Color(red: 0x18/255, green: 0x1A/255, blue: 0x20/255)   // #181A20

    // MARK: - Score semantics (identical in both modes — text color)
    static let scorePositive = Color(red: 0x0E/255, green: 0xCB/255, blue: 0x81/255)   // #0ECB81
    static let scoreNegative = Color(red: 0xF6/255, green: 0x46/255, blue: 0x5D/255)   // #F6465D
    static let warning       = Color(red: 0xFF/255, green: 0x95/255, blue: 0x00/255)   // #FF9500
    static let phormMuted    = Color(red: 0x70/255, green: 0x7A/255, blue: 0x8A/255)   // #707A8A — neutral in both modes

    // MARK: - Adaptive (resolved from Assets.xcassets)
    static let canvas             = Color("Canvas")
    static let surfaceCard        = Color("SurfaceCard")
    static let surfaceElevated    = Color("SurfaceElevated")
    static let surfaceSoft        = Color("SurfaceSoft")
    static let hairline           = Color("Hairline")
    static let bodyText           = Color("Body")
    static let mutedStrong        = Color("MutedStrong")
    static let focusRowTint       = Color("FocusRowTint")
    static let scorePositiveTint  = Color("ScorePositiveTint")
    static let scoreNegativeTint  = Color("ScoreNegativeTint")
}
