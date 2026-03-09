import Foundation

@Observable
class GameResultRepository {
    var results: [GameResult] = []

    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("game_results.json")
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let loaded = try? JSONDecoder().decode([GameResult].self, from: data) else { return }
        results = loaded
    }

    func save(_ result: GameResult) {
        results.append(result)
        if let data = try? JSONEncoder().encode(results) {
            try? data.write(to: fileURL)
        }
    }

    func resultsForGameSet(_ index: Int) -> [GameResult] {
        results.filter { $0.gameSetIndex == index }
    }

    func bestMoves(_ index: Int) -> Int? {
        resultsForGameSet(index).map(\.moves).min()
    }

    func bestTime(_ index: Int) -> Int? {
        resultsForGameSet(index).map(\.durationSeconds).min()
    }

    func averageMoves() -> Double? {
        guard !results.isEmpty else { return nil }
        return Double(results.map(\.moves).reduce(0, +)) / Double(results.count)
    }

    func currentStreak() -> Int {
        results.sorted { $0.timestamp > $1.timestamp }
            .prefix(while: { $0.matchCount == 12 })
            .count
    }

    func topResults(_ index: Int, limit: Int = 5) -> [GameResult] {
        Array(resultsForGameSet(index).sorted { $0.moves < $1.moves }.prefix(limit))
    }
}
