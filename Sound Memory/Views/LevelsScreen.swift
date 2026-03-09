import SwiftUI

struct LevelsScreen: View {
    let viewModel: SoundMemoryViewModel
    let onGameSelected: (Int) -> Void

    private var filteredGames: [GameSet] {
        viewModel.gameSets.filter { $0.language == viewModel.settings.language }
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(filteredGames, id: \.index) { gameSet in
                    GameSetItemView(gameSet: gameSet) {
                        onGameSelected(gameSet.index)
                    }
                }
            }
            .padding(8)
        }
        .navigationTitle("Select Game")
    }
}

private struct GameSetItemView: View {
    let gameSet: GameSet
    let onTap: () -> Void

    @State private var image: UIImage?

    var body: some View {
        Button(action: onTap) {
            ZStack {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Text(gameSet.title.isEmpty ? "Game \(gameSet.index + 1)" : gameSet.title)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(8)
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .task {
            if !gameSet.deckImage.isEmpty {
                image = loadGameImage(named: gameSet.deckImage)
            }
        }
    }
}
