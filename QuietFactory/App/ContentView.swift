import SpriteKit
import SwiftUI

struct ContentView: View {
    @StateObject private var levelPicker = LevelPickerModel()

    var body: some View {
        VStack(spacing: 0) {
            header
            GameplayContainer(
                session: levelPicker.session,
                onRestart: { levelPicker.session.restart() },
                onAdvance: { levelPicker.advanceLevel() }
            )
            levelStrip
        }
        .background(Color(white: 0.12))
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Quiet Factory")
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(levelPicker.session.level.name)
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
            Spacer()
            Button("RESTART") {
                HapticsManager.selection()
                levelPicker.session.restart()
            }
            .font(.subheadline.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(white: 0.28))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private var levelStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(LevelCatalog.all.enumerated()), id: \.element.id) { index, level in
                    Button(level.id) {
                        levelPicker.selectLevel(at: index)
                    }
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        levelPicker.selectedIndex == index
                            ? Color.white.opacity(0.25)
                            : Color.white.opacity(0.08)
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }
}

final class LevelPickerModel: ObservableObject {
    @Published var selectedIndex: Int = 0
    @Published var session: GameSession

    init() {
        session = GameSession(level: LevelCatalog.all[0])
    }

    func selectLevel(at index: Int) {
        guard index >= 0 && index < LevelCatalog.all.count else { return }
        selectedIndex = index
        session = GameSession(level: LevelCatalog.all[index])
        HapticsManager.selection()
    }

    func advanceLevel() {
        let next = min(selectedIndex + 1, LevelCatalog.all.count - 1)
        if next != selectedIndex {
            selectLevel(at: next)
        }
    }
}

struct GameplayContainer: UIViewRepresentable {
    @ObservedObject var session: GameSession
    var onRestart: () -> Void
    var onAdvance: () -> Void

    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.ignoresSiblingOrder = true
        view.preferredFramesPerSecond = 60
        let scene = GameScene(size: CGSize(width: 390, height: 844))
        scene.scaleMode = .resizeFill
        scene.attach(session: session)
        scene.onLevelComplete = onAdvance
        context.coordinator.scene = scene
        context.coordinator.skView = view
        view.presentScene(scene)
        return view
    }

    func updateUIView(_ uiView: SKView, context: Context) {
        guard let scene = context.coordinator.scene else { return }

        let sessionID = ObjectIdentifier(session)
        let needsHardRefresh =
            context.coordinator.boundSessionID != sessionID
            || context.coordinator.boundRevision != session.sceneRevision

        scene.size = uiView.bounds.size

        if needsHardRefresh {
            scene.resetAndAttach(session: session)
            context.coordinator.boundSessionID = sessionID
            context.coordinator.boundRevision = session.sceneRevision
            return
        }

        if scene.isSceneAnimating { return }
        scene.attach(session: session)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator {
        var scene: GameScene?
        var skView: SKView?
        var boundSessionID: ObjectIdentifier?
        var boundRevision: Int = -1
    }
}
