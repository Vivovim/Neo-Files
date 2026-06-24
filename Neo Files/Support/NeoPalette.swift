import SwiftUI

enum NeoPalette {
    static let background = Color.black
    static let panel = Color(red: 0.03, green: 0.09, blue: 0.06)
    static let panelSecondary = Color(red: 0.05, green: 0.13, blue: 0.08)
    static let primary = Color(red: 0.36, green: 1.0, blue: 0.48)
    static let secondary = Color(red: 0.65, green: 1.0, blue: 0.72)
    static let border = Color(red: 0.2, green: 1.0, blue: 0.35, opacity: 0.34)
    static let selection = Color(red: 0.14, green: 0.42, blue: 0.19, opacity: 0.7)
}

struct NeoButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .foregroundStyle(NeoPalette.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(NeoPalette.panelSecondary.opacity(configuration.isPressed ? 0.75 : 1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(NeoPalette.border, lineWidth: 1)
            )
            .shadow(color: NeoPalette.primary.opacity(configuration.isPressed ? 0.15 : 0.3), radius: 8)
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
    }
}

extension View {
    func neoPanel() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(NeoPalette.panel)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(NeoPalette.border, lineWidth: 1)
            )
    }
}
