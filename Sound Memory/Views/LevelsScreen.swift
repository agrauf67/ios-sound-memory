import SwiftUI

struct LevelsScreen: View {
    let viewModel: SoundMemoryViewModel
    let onGameSelected: (Int) -> Void

    @State private var showStore = false
    @State private var unlockTarget: Int?

    private var filteredGames: [GameSet] {
        viewModel.gameSets.filter { $0.language == viewModel.settings.language }
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(filteredGames, id: \.index) { gameSet in
                    let locked = !viewModel.storeManager.isCategoryUnlocked(gameSet.category)
                    GameSetItemView(gameSet: gameSet, locked: locked) {
                        if locked {
                            unlockTarget = gameSet.category
                        } else {
                            onGameSelected(gameSet.index)
                        }
                    }
                }
            }
            .padding(8)
        }
        .navigationTitle("Select Game")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showStore = true
                } label: {
                    Label("Store", systemImage: "cart")
                }
            }
        }
        .sheet(isPresented: $showStore) {
            NavigationStack {
                StoreScreen(storeManager: viewModel.storeManager)
            }
        }
        .alert("Unlock Game", isPresented: Binding(
            get: { unlockTarget != nil },
            set: { if !$0 { unlockTarget = nil } }
        )) {
            if viewModel.storeManager.unlockCredits > 0 {
                Button("Use 1 Credit") {
                    if let cat = unlockTarget {
                        _ = viewModel.storeManager.unlockCategory(cat)
                    }
                    unlockTarget = nil
                }
            }
            Button("Go to Store") {
                unlockTarget = nil
                showStore = true
            }
            Button("Cancel", role: .cancel) {
                unlockTarget = nil
            }
        } message: {
            if viewModel.storeManager.unlockCredits > 0 {
                Text("Use 1 credit to unlock this game? You have \(viewModel.storeManager.unlockCredits) credits.")
            } else {
                Text("You need credits to unlock this game. Visit the store to buy a game pack.")
            }
        }
    }
}

private struct GameSetItemView: View {
    let gameSet: GameSet
    let locked: Bool
    let onTap: () -> Void

    @State private var image: UIImage?

    var body: some View {
        Button(action: onTap) {
            ZStack {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .opacity(locked ? 0.4 : 1)
                } else {
                    Text(gameSet.title.isEmpty ? "Game \(gameSet.index + 1)" : gameSet.title)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(8)
                        .opacity(locked ? 0.4 : 1)
                }

                if locked {
                    Image(systemName: "lock.fill")
                        .font(.title)
                        .foregroundStyle(.secondary)
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
