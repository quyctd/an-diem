import SwiftUI
import UIKit

extension Font {
    // MARK: - Editorial (scales with Dynamic Type via system text styles)
    static let phormTitleSm   = Font.headline                              // 17 / 600
    static let phormBodyMd    = Font.subheadline                           // 15 / 400
    static let phormBodySm    = Font.footnote                              // 13 / 400
    static let phormCaption   = Font.caption.weight(.medium)               // 12 / 500
    static let phormTitleLg   = Font.title2.weight(.semibold)              // 22 / 600
    static let phormTitleMd   = Font.title3.weight(.semibold)              // 20 / 600
    static let phormDisplayMd = Font.title.weight(.semibold)               // 28 / 600
    static let phormButton    = Font.headline                              // 17 / 600

    // MARK: - Editorial outliers — UIFontMetrics-scaled
    static let phormDisplayLg    = Font.scaled(32, weight: .bold,     relativeTo: .largeTitle)
    static let phormHeroDisplay  = Font.scaled(40, weight: .bold,     relativeTo: .largeTitle)
    static let phormCaptionSection = Font.scaled(10, weight: .semibold, relativeTo: .caption2)

    // MARK: - Numerics (fixed size — column alignment over Dynamic Type)
    static let phormNumberRanking = Font.system(size: 28, weight: .bold,     design: .monospaced)
    static let phormNumberEntry   = Font.system(size: 22, weight: .semibold, design: .monospaced)
    static let phormNumberMd      = Font.system(size: 17, weight: .medium,   design: .monospaced)
    static let phormNumberSm      = Font.system(size: 15, weight: .medium,   design: .monospaced)
    static let phormNumberChip    = Font.system(size: 17, weight: .bold,     design: .monospaced)

    // MARK: - Keypad (fixed — bounded by key size)
    static let phormKeypadDigit = Font.system(size: 26, weight: .regular)

    // MARK: - Helpers
    fileprivate static func scaled(
        _ size: CGFloat,
        weight: UIFont.Weight,
        relativeTo style: UIFont.TextStyle
    ) -> Font {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        return Font(UIFontMetrics(forTextStyle: style).scaledFont(for: base))
    }
}
