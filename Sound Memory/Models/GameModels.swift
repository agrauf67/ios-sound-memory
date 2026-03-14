import SwiftUI

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
    let overviewImageDir: String?
}

nonisolated struct GameSetsRoot: Codable, Sendable {
    let gameSets: [GameSetJSON]
}

struct GameSet: Identifiable, Sendable {
    var id: Int { index }
    let index: Int
    let category: Int
    let language: String
    let title: String
    let deckImage: String
    let cards: [CardInfo]
    let overviewImageDir: String?
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
    let gameMode: Int
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

    var gameModeName: LocalizedStringKey {
        switch gameMode {
        case 1: return "Speech only"
        case 2: return "Image only"
        case 3: return "Speech + Image"
        default: return "Speech only"
        }
    }

    init(gameSetIndex: Int, gameSetTitle: String, language: String, gameMode: Int, moves: Int, durationSeconds: Int, matchCount: Int, totalAttempts: Int, timestamp: Date) {
        self.gameSetIndex = gameSetIndex
        self.gameSetTitle = gameSetTitle
        self.language = language
        self.gameMode = gameMode
        self.moves = moves
        self.durationSeconds = durationSeconds
        self.matchCount = matchCount
        self.totalAttempts = totalAttempts
        self.timestamp = timestamp
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        gameSetIndex = try container.decode(Int.self, forKey: .gameSetIndex)
        gameSetTitle = try container.decode(String.self, forKey: .gameSetTitle)
        language = try container.decode(String.self, forKey: .language)
        gameMode = try container.decodeIfPresent(Int.self, forKey: .gameMode) ?? 1
        moves = try container.decode(Int.self, forKey: .moves)
        durationSeconds = try container.decode(Int.self, forKey: .durationSeconds)
        matchCount = try container.decode(Int.self, forKey: .matchCount)
        totalAttempts = try container.decode(Int.self, forKey: .totalAttempts)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
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
