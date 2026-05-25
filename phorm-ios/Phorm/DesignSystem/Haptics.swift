import UIKit

/// Pre-warmed haptic generators for the round-entry keypad and other tap surfaces.
/// Generators are created once at app start; `prepare()` keeps the Taptic Engine
/// awake before the next tap so latency stays under ~10ms.
enum Haptics {
    private static let light = {
        let g = UIImpactFeedbackGenerator(style: .light)
        g.prepare()
        return g
    }()
    private static let medium = {
        let g = UIImpactFeedbackGenerator(style: .medium)
        g.prepare()
        return g
    }()
    private static let selection = {
        let g = UISelectionFeedbackGenerator()
        g.prepare()
        return g
    }()
    private static let notification = {
        let g = UINotificationFeedbackGenerator()
        g.prepare()
        return g
    }()

    /// Soft tap — every digit key on the keypad.
    static func tap() {
        light.impactOccurred(intensity: 0.6)
        light.prepare()
    }

    /// Slightly heavier — sign toggle, delete, anything that changes the value's state.
    static func toggle() {
        medium.impactOccurred(intensity: 0.7)
        medium.prepare()
    }

    /// Navigational — "Tiếp" / focus change.
    static func nav() {
        selection.selectionChanged()
        selection.prepare()
    }

    /// Round successfully committed — "Đóng dấu" save.
    static func success() {
        notification.notificationOccurred(.success)
        notification.prepare()
    }

    /// Soft warning — non-blocking validation problem.
    static func warn() {
        notification.notificationOccurred(.warning)
        notification.prepare()
    }
}
