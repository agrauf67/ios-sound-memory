import Foundation
import Combine

@MainActor
class SoundMemoryViewModel: ObservableObject {

    @Published var cards: [MemoryCard] = []
    @Published var moves: Int = 0
    @Published var matchesFound: Int = 0
    @Published var isGameComplete: Bool = false

    let soundManager = SoundManager()
    let settingsManager = SettingsManager()

    private var firstFlippedId: Int?
    private var isChecking = false

    init() {
        initGame()
    }

    func initGame() {
        // Pick 12 random images from 0001..0014
        let imageNumbers = Array(1...14).shuffled().prefix(12)
        let imageFileNames = imageNumbers.map { String(format: "%04d", $0) }

        // Each image appears twice, then shuffle
        var cardList: [MemoryCard] = []
        for (index, fileName) in imageFileNames.enumerated() {
            cardList.append(MemoryCard(id: index * 2, imageFileName: fileName))
            cardList.append(MemoryCard(id: index * 2 + 1, imageFileName: fileName))
        }
        cardList.shuffle()

        cards = cardList
        moves = 0
        matchesFound = 0
        isGameComplete = false
        firstFlippedId = nil
        isChecking = false
    }

    func onCardClicked(cardId: Int) {
        if isChecking { return }

        guard let cardIndex = cards.firstIndex(where: { $0.id == cardId }) else { return }
        let card = cards[cardIndex]

        // Ignore already flipped or matched cards
        if card.isFlipped || card.isMatched { return }

        // Flip the card
        cards[cardIndex].isFlipped = true

        if firstFlippedId == nil {
            // First card of the pair
            firstFlippedId = cardId
        } else {
            // Second card — check for match
            let firstId = firstFlippedId!
            firstFlippedId = nil
            moves += 1

            guard let firstIndex = cards.firstIndex(where: { $0.id == firstId }) else { return }
            let firstCard = cards[firstIndex]
            let secondCard = cards[cardIndex]

            if firstCard.imageFileName == secondCard.imageFileName {
                // Match found
                cards[firstIndex].isMatched = true
                cards[cardIndex].isMatched = true
                matchesFound += 1
                if matchesFound == 12 {
                    isGameComplete = true
                }
            } else {
                // No match — flip back after delay
                isChecking = true
                Task {
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    if let idx1 = cards.firstIndex(where: { $0.id == firstId }) {
                        cards[idx1].isFlipped = false
                    }
                    if let idx2 = cards.firstIndex(where: { $0.id == cardId }) {
                        cards[idx2].isFlipped = false
                    }
                    isChecking = false
                }
            }
        }
    }

    func resetGame() {
        initGame()
    }
}
