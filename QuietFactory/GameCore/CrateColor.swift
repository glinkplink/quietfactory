import Foundation

enum CrateColor: String, CaseIterable, Codable, Sendable {
    case red
    case blue
    case green
    case yellow
    case orange
    case purple

    /// Gray-box placeholder palette (display only).
    var displayHue: (red: CGFloat, green: CGFloat, blue: CGFloat) {
        switch self {
        case .red: (0.90, 0.25, 0.25)
        case .blue: (0.25, 0.55, 0.95)
        case .green: (0.30, 0.80, 0.45)
        case .yellow: (0.95, 0.85, 0.25)
        case .orange: (0.95, 0.55, 0.20)
        case .purple: (0.65, 0.35, 0.90)
        }
    }
}
