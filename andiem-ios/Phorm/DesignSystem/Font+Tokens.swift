import SwiftUI
import UIKit

/// An Điểm typography — system SF Pro (humanist sans, full Vietnamese diacritics, Dynamic Type).
/// See DESIGN.md and themes-preview.html for the canonical visual.
///
/// All tokens use `.system(_, design: .default)` — SwiftUI resolves this to SF Pro on iOS,
/// which provides full Vietnamese diacritic coverage and supports Dynamic Type scaling.
/// Numerals use `.monospacedDigit()` for tabular figures. SF Mono is forbidden anywhere in the app.
extension Font {
    // MARK: - Display tier
    /// Hero — end-of-session champion name, empty-state title. 40pt / weight 800.
    static let phormHeroDisplay  = Font.scaledSans(40, weight: .heavy, relativeTo: .largeTitle)
    /// Largest display — session titles, summary header. 32pt / 800.
    static let phormDisplayLg    = Font.scaledSans(32, weight: .heavy, relativeTo: .largeTitle)
    /// Standalone modal titles, end-of-session subtitle. 28pt / 700.
    static let phormDisplayMd    = Font.system(size: 28, weight: .bold, design: .default)
    /// Session header in nav bar. 22pt / 700.
    static let phormTitleLg      = Font.system(size: 22, weight: .bold, design: .default)
    /// Sheet headers, section dividers. 20pt / 700.
    static let phormTitleMd      = Font.system(size: 20, weight: .bold, design: .default)
    /// Default nav title, player names in round-entry rows. 17pt / 600.
    static let phormTitleSm      = Font.system(size: 17, weight: .semibold, design: .default)

    // MARK: - Body tier
    /// Body copy, button labels. 15pt / 400.
    static let phormBodyMd       = Font.system(size: 15, weight: .regular, design: .default)
    /// Secondary meta, player lists in history rows. 13pt / 400.
    static let phormBodySm       = Font.system(size: 13, weight: .regular, design: .default)
    /// Round-card "Ván N" label, time meta. 12pt / 500.
    static let phormCaption      = Font.system(size: 12, weight: .medium, design: .default)
    /// Section labels — "PHIÊN ĐANG CHƠI", "VÒNG", "TỔNG". 11pt uppercase, letter-spaced via .tracking.
    static let phormCaptionSection = Font.scaledSans(11, weight: .semibold, relativeTo: .caption2)
    /// Primary CTA label. 14pt / 600 uppercase — letter-spacing applied via .tracking at use site.
    static let phormButton       = Font.system(size: 14, weight: .semibold, design: .default)

    // MARK: - Player names
    /// Player display name — semibold sans for legibility. 22pt / 600.
    static let phormNameDisplay  = Font.system(size: 22, weight: .semibold, design: .default)
    /// Player name in round-entry rows. 18pt / 600.
    static let phormNameMd       = Font.system(size: 18, weight: .semibold, design: .default)

    // MARK: - Numerals (tabular figures via .monospacedDigit())
    /// Champion +24 on end-of-session — biggest number on screen. 44pt / 800.
    static let phormNumberHero    = Font.system(size: 44, weight: .heavy, design: .default).monospacedDigit()
    /// Leaderboard totals, ranking values. 26pt / 800.
    static let phormNumberRanking = Font.system(size: 26, weight: .heavy, design: .default).monospacedDigit()
    /// Round-entry value inputs. 22pt / 700.
    static let phormNumberEntry   = Font.system(size: 22, weight: .bold, design: .default).monospacedDigit()
    /// Focused round-entry value — dominant number on the entry screen. 34pt / 800.
    static let phormNumberEntryFocused = Font.system(size: 34, weight: .heavy, design: .default).monospacedDigit()
    /// Round-card inline scores. 17pt / 600.
    static let phormNumberMd      = Font.system(size: 17, weight: .semibold, design: .default).monospacedDigit()
    /// Round history strip, dense meta. 15pt / 500.
    static let phormNumberSm      = Font.system(size: 15, weight: .medium, design: .default).monospacedDigit()
    /// Score chip running total. 17pt / 700.
    static let phormNumberChip    = Font.system(size: 17, weight: .bold, design: .default).monospacedDigit()
    /// Auto-fill computed value — regular weight distinguishes "machine wrote this" from "host wrote this".
    static let phormNumberScript  = Font.system(size: 22, weight: .regular, design: .default).monospacedDigit()

    // MARK: - Keypad
    /// Custom keypad digits 0-9 on RoundEntryView. 26pt / 500 — slightly heavier than system keyboard.
    static let phormKeypadDigit  = Font.system(size: 26, weight: .medium, design: .default).monospacedDigit()

    // MARK: - Helpers
    fileprivate static func scaledSans(
        _ size: CGFloat,
        weight: UIFont.Weight,
        relativeTo style: UIFont.TextStyle
    ) -> Font {
        let descriptor = UIFont.systemFont(ofSize: size, weight: weight).fontDescriptor
            .withDesign(.default) ?? UIFont.systemFont(ofSize: size, weight: weight).fontDescriptor
        let base = UIFont(descriptor: descriptor, size: size)
        return Font(UIFontMetrics(forTextStyle: style).scaledFont(for: base))
    }
}
