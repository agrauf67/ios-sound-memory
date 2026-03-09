import SwiftUI

struct PlayScreen: View {
    let viewModel: SoundMemoryViewModel

    var body: some View {
        Group {
            if viewModel.selectedGameIndex < 0 || viewModel.cards.isEmpty {
                ContentUnavailableView(
                    "Select a Game",
                    systemImage: "square.grid.3x3",
                    description: Text("Please select a game under \"Games\"")
                )
            } else {
                GameBoardView(viewModel: viewModel)
            }
        }
        .navigationTitle("Sound Memory")
        .toolbar {
            if viewModel.selectedGameIndex >= 0 && !viewModel.cards.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.resetGame()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                }
            }
        }
        .onChange(of: viewModel.isGameComplete) { _, complete in
            if complete {
                Task {
                    try? await Task.sleep(for: .seconds(viewModel.settings.gameCompleteSeconds))
                    viewModel.resetGame()
                }
            }
        }
    }
}

private struct GameBoardView: View {
    let viewModel: SoundMemoryViewModel
    private let columns = 4
    private let rows = 6

    var body: some View {
        let deckImageName = viewModel.gameSets[safe: viewModel.selectedGameIndex]?.deckImage ?? ""
        let deckImage = deckImageName.isEmpty ? nil : loadGameImage(named: deckImageName)

        VStack(spacing: 6) {
            HStack {
                Spacer()
                Text("\(viewModel.moves) moves")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal)

            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(0..<columns, id: \.self) { col in
                        let index = row * columns + col
                        if index < viewModel.cards.count {
                            let card = viewModel.cards[index]
                            let label = viewModel.flippedCardLabels[card.id]
                            let cardNumber: Int = {
                                guard let l = label else { return 0 }
                                if l.hasSuffix("1") { return 1 }
                                if l.hasSuffix("2") { return 2 }
                                return 0
                            }()

                            MemoryCardView(
                                card: card,
                                deckImage: deckImage,
                                isSpeaking: viewModel.speakingCardIds.contains(card.id),
                                cardNumber: cardNumber,
                                showImageOnFlip: viewModel.settings.gameMode >= 2
                            ) {
                                viewModel.onCardClicked(card.id)
                            }
                        }
                    }
                }
            }
        }
        .padding(8)
    }
}

private struct MemoryCardView: View {
    let card: MemoryCard
    let deckImage: UIImage?
    let isSpeaking: Bool
    let cardNumber: Int
    let showImageOnFlip: Bool
    let onTap: () -> Void

    @State private var cardImage: UIImage?

    private var isShowingFront: Bool { card.isFlipped || card.isMatched }
    private var showCardImage: Bool { card.isMatched || (card.isFlipped && showImageOnFlip) }

    private var borderColor: Color {
        switch cardNumber {
        case 1: Color(red: 0.098, green: 0.463, blue: 0.824)
        case 2: Color(red: 0.961, green: 0.486, blue: 0)
        default: .clear
        }
    }

    var body: some View {
        Button(action: onTap) {
            ZStack {
                if !isShowingFront {
                    // Back side
                    if let deckImage {
                        Image(uiImage: deckImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Image(systemName: "questionmark")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    // Front side
                    if showCardImage, let cardImage {
                        Image(uiImage: cardImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }

                    if isSpeaking {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.title2)
                            .foregroundStyle(.tint)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: cardNumber > 0 ? 3 : 0)
            )
        }
        .buttonStyle(.plain)
        .rotation3DEffect(
            .degrees(isShowingFront ? 180 : 0),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.3
        )
        .animation(.easeInOut(duration: 0.4), value: isShowingFront)
        .task {
            cardImage = loadGameImage(named: card.imageFileName)
        }
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
