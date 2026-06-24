import SwiftUI

struct SelectionStatusView: View {
    let rootPath: String
    let stagedDescription: String
    let onClearMove: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("ROOT \(rootPath)")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(NeoPalette.secondary)

                Text("MOVE QUEUE \(stagedDescription)")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(NeoPalette.primary)
            }

            Spacer(minLength: 12)

            Button("Clear Move") {
                onClearMove()
            }
            .buttonStyle(NeoButtonStyle())
        }
        .padding(14)
        .neoPanel()
    }
}
