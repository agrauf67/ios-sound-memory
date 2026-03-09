import UIKit

nonisolated struct CardInfo: Codable, Sendable {
    let name: String
    let text1: String
    let text2: String
}

nonisolated struct DeckCard: Codable, Sendable {
    let name: String
    let image: String
    let text1: String
    let text2: String
}

nonisolated struct GameSetJSON: Codable, Sendable {
    let language: String
    let deckcard: DeckCard
    let cards: [CardInfo]
}

nonisolated struct GameSetsRoot: Codable, Sendable {
    let gameSets: [GameSetJSON]
}

struct GameSet: Sendable {
    let index: Int
    let language: String
    let title: String
    let deckImage: String
    let cards: [CardInfo]
}

struct MemoryCard: Identifiable, Sendable {
    let id: Int
    let imageFileName: String
    let text: String
    let easyText: String
    let language: String
    var isFlipped: Bool = false
    var isMatched: Bool = false
}

struct GameResult: Codable, Identifiable, Sendable {
    var id = UUID()
    let gameSetIndex: Int
    let gameSetTitle: String
    let language: String
    let moves: Int
    let durationSeconds: Int
    let matchCount: Int
    let totalAttempts: Int
    let timestamp: Date

    var accuracyPercent: Int {
        totalAttempts > 0 ? (matchCount * 100) / totalAttempts : 0
    }

    var stars: Int {
        if moves <= 12 { return 3 }
        if moves <= 18 { return 2 }
        return 1
    }
}

func loadGameImage(named fileName: String) -> UIImage? {
    let name = (fileName as NSString).deletingPathExtension
    let ext = (fileName as NSString).pathExtension
    let fileExt = ext.isEmpty ? "jpg" : ext
    if let path = Bundle.main.path(forResource: name, ofType: fileExt, inDirectory: "GameImages") {
        return UIImage(contentsOfFile: path)
    }
    if let path = Bundle.main.path(forResource: name, ofType: fileExt) {
        return UIImage(contentsOfFile: path)
    }
    return nil
}
