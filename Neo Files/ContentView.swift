import SwiftUI

struct ContentView: View {
    @StateObject private var store = FileBrowserStore()

    var body: some View {
        ZStack {
            NeoPalette.background
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {
                header

                if store.columns.isEmpty {
                    emptyState
                } else {
                    if store.stagedMove != nil {
                        SelectionStatusView(
                            rootPath: store.rootPathText,
                            stagedDescription: store.stagedMoveDescription,
                            onClearMove: store.clearStagedMove
                        )
                    } else {
                        Text(store.rootPathText)
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundStyle(NeoPalette.secondary)
                    }

                    ScrollView(.horizontal, showsIndicators: true) {
                        HStack(alignment: .top, spacing: 18) {
                            ForEach(Array(store.columns.indices), id: \.self) { index in
                                BrowserColumnView(
                                    column: store.columns[index],
                                    selectedURL: store.selectedURL(for: index),
                                    selectedEntry: store.selectedEntry(in: index),
                                    stagedMove: store.stagedMove,
                                    canMoveHere: store.canMoveStagedItem(to: store.columns[index].directoryURL),
                                    onSelect: { store.select($0, in: index) },
                                    onStageSelection: { store.stageSelection(in: index) },
                                    onMoveHere: { store.moveStagedItem(to: store.columns[index].directoryURL) }
                                )
                            }
                        }
                        .padding(.bottom, 8)
                    }
                }
            }
            .padding(24)
        }
        .preferredColorScheme(.dark)
        .alert(
            store.alertContext?.title ?? "Neo Files",
            isPresented: Binding(
                get: { store.alertContext != nil },
                set: { isPresented in
                    if !isPresented {
                        store.dismissAlert()
                    }
                }
            ),
            presenting: store.alertContext
        ) { _ in
            Button("OK") {
                store.dismissAlert()
            }
        } message: { context in
            Text(context.message)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

private extension ContentView {
    var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Neo Files")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(NeoPalette.primary)
                    .shadow(color: NeoPalette.primary.opacity(0.45), radius: 12)

                Text("Column-first file browsing with live folder counts, file-type summaries, and move controls.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(NeoPalette.secondary)
            }

            Spacer(minLength: 24)

            HStack(spacing: 10) {
                Button("Choose Root Folder") {
                    store.chooseRootFolder()
                }
                .buttonStyle(NeoButtonStyle())

                Button("Refresh") {
                    store.refresh()
                }
                .buttonStyle(NeoButtonStyle())
                .disabled(store.rootURL == nil)

                Button("Clear Move") {
                    store.clearStagedMove()
                }
                .buttonStyle(NeoButtonStyle())
                .disabled(store.stagedMove == nil)
            }
        }
    }

    var emptyState: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("No folder selected")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(NeoPalette.primary)

            Text("Pick a root folder to light up the browser. Each column will show folder counts, file-type totals, and destination controls for moving files or folders.")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(NeoPalette.secondary)
                .frame(maxWidth: 560, alignment: .leading)

            Button("Choose Root Folder") {
                store.chooseRootFolder()
            }
            .buttonStyle(NeoButtonStyle())
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .neoPanel()
    }
}
