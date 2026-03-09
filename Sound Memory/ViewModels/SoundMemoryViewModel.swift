import SwiftUI

@Observable
class SoundMemoryViewModel {
    let settings = SettingsManager()
    let gameResultRepository = GameResultRepository()
    let gameSets: [GameSet]
    private let ttsManager = TtsManager()

    var selectedGameIndex: Int = -1
    var moves: Int = 0
    var matchesFound: Int = 0
    var isGameComplete: Bool = false
    var cards: [MemoryCard] = []
    var speakingCardIds: Set<Int> = []
    var flippedCardLabels: [Int: String] = [:]

    private var firstFlippedId: Int?
    private var gameStartTime = Date()
    private var totalAttempts: Int = 0
    private var pendingFlipBackIds: (Int, Int)?
    private var pendingFlipTask: Task<Void, Never>?

    init() {
        gameSets = Self.loadGameSets()
        ttsManager.onSpeakingChanged = { [weak self] isSpeaking in
            guard let self else { return }
            if !isSpeaking {
                self.speakingCardIds = []
            }
        }
        gameResultRepository.load()
    }

    func selectGame(_ index: Int) {
        selectedGameIndex = index
        initGame()
    }

    func initGame() {
        guard selectedGameIndex >= 0, selectedGameIndex < gameSets.count else { return }
        let gameSet = gameSets[selectedGameIndex]
        let selected = Array(gameSet.cards.shuffled().prefix(12))

        var cardList: [MemoryCard] = []
        for (i, cardInfo) in selected.enumerated() {
            let fileName = "\(cardInfo.name).jpg"
            cardList.append(MemoryCard(id: i * 2, imageFileName: fileName,
                                       text: cardInfo.text1, easyText: cardInfo.text2,
                                       language: gameSet.language))
            cardList.append(MemoryCard(id: i * 2 + 1, imageFileName: fileName,
                                       text: cardInfo.text1, easyText: cardInfo.text2,
                                       language: gameSet.language))
        }

        cards = cardList.shuffled()
        moves = 0
        matchesFound = 0
        isGameComplete = false
        firstFlippedId = nil
        gameStartTime = Date()
        totalAttempts = 0
        speakingCardIds = []
        flippedCardLabels = [:]
        pendingFlipBackIds = nil
        pendingFlipTask?.cancel()
        pendingFlipTask = nil
    }

    func resetGame() {
        ttsManager.stop()
        initGame()
    }

    func onCardClicked(_ cardId: Int) {
        guard cards.contains(where: { $0.id == cardId }) else { return }
        let card = cards.first { $0.id == cardId }!

        if card.isFlipped || card.isMatched { return }

        let flippedUnmatched = cards.filter { $0.isFlipped && !$0.isMatched }.count
        if flippedUnmatched >= 2 {
            flipBackPending()
        }

        if let idx = cards.firstIndex(where: { $0.id == cardId }) {
            cards[idx].isFlipped = true
        }

        let gameMode = settings.gameMode
        let shouldSpeak = gameMode != 2
        let useOfficial = settings.useOfficialText
        let speakText = useOfficial ? card.text : (card.easyText.isEmpty ? card.text : card.easyText)
        let labels = cardLabelsForLanguage(card.language)

        if firstFlippedId == nil {
            if shouldSpeak {
                speakingCardIds = [cardId]
                ttsManager.speak(speakText, language: card.language, gender: settings.voiceGender)
            }
            flippedCardLabels = [cardId: labels.0]
            firstFlippedId = cardId
        } else {
            let firstId = firstFlippedId!
            firstFlippedId = nil

            if shouldSpeak {
                speakingCardIds = [firstId, cardId]
                ttsManager.speak(speakText, language: card.language, gender: settings.voiceGender)
            }
            flippedCardLabels = [firstId: labels.0, cardId: labels.1]
            moves += 1
            totalAttempts += 1

            let firstCard = cards.first { $0.id == firstId }!
            let isMatch = firstCard.imageFileName == card.imageFileName

            let displayDelay = UInt64(settings.cardDisplaySeconds) * 1_000_000_000
            let capturedFirstId = firstId

            if isMatch {
                for i in cards.indices {
                    if cards[i].id == capturedFirstId || cards[i].id == cardId {
                        cards[i].isMatched = true
                    }
                }
                matchesFound += 1
                if matchesFound == 12 {
                    isGameComplete = true
                    saveGameResult()
                }
                pendingFlipTask = Task {
                    try? await Task.sleep(nanoseconds: displayDelay)
                    guard !Task.isCancelled else { return }
                    speakingCardIds = []
                    flippedCardLabels = [:]
                }
            } else {
                pendingFlipBackIds = (capturedFirstId, cardId)
                pendingFlipTask = Task {
                    try? await Task.sleep(nanoseconds: displayDelay)
                    guard !Task.isCancelled else { return }
                    speakingCardIds = []
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    guard !Task.isCancelled else { return }
                    flippedCardLabels = [:]
                    for i in cards.indices {
                        if cards[i].id == capturedFirstId || cards[i].id == cardId {
                            cards[i].isFlipped = false
                        }
                    }
                    pendingFlipBackIds = nil
                }
            }
        }
    }

    private func flipBackPending() {
        pendingFlipTask?.cancel()
        pendingFlipTask = nil
        guard let ids = pendingFlipBackIds else { return }
        pendingFlipBackIds = nil
        speakingCardIds = []
        flippedCardLabels = [:]
        for i in cards.indices {
            if cards[i].id == ids.0 || cards[i].id == ids.1 {
                cards[i].isFlipped = false
            }
        }
    }

    private func saveGameResult() {
        guard selectedGameIndex >= 0, selectedGameIndex < gameSets.count else { return }
        let gameSet = gameSets[selectedGameIndex]
        let duration = Int(Date().timeIntervalSince(gameStartTime))
        let result = GameResult(
            gameSetIndex: selectedGameIndex,
            gameSetTitle: gameSet.title,
            language: gameSet.language,
            gameMode: settings.gameMode,
            moves: moves,
            durationSeconds: duration,
            matchCount: matchesFound,
            totalAttempts: totalAttempts,
            timestamp: Date()
        )
        gameResultRepository.save(result)
    }

    private func cardLabelsForLanguage(_ language: String) -> (String, String) {
        if language.hasPrefix("de") { return ("KARTE 1", "KARTE 2") }
        if language.hasPrefix("fr") { return ("CARTE 1", "CARTE 2") }
        if language.hasPrefix("es") { return ("NAIPE 1", "NAIPE 2") }
        return ("CARD 1", "CARD 2")
    }

    nonisolated static func loadGameSets() -> [GameSet] {
        guard let url = Bundle.main.url(forResource: "gamesets", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let root = try? JSONDecoder().decode(GameSetsRoot.self, from: data) else {
            return []
        }

        return root.gameSets.enumerated().map { index, json in
            GameSet(
                index: index,
                language: json.language,
                title: json.deckcard.text1,
                deckImage: json.deckcard.image.isEmpty ? "" : json.deckcard.image,
                cards: json.cards
            )
        }
    }
}
