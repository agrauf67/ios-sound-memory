import SwiftUI

struct StatsScreen: View {
    let viewModel: SoundMemoryViewModel

    private var results: [GameResult] { viewModel.gameResultRepository.results }

    var body: some View {
        Group {
            if results.isEmpty {
                ContentUnavailableView(
                    "No Games Played",
                    systemImage: "chart.bar",
                    description: Text("Play a game to see your statistics here.")
                )
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        lifetimeStatsCard
                        lastGameCard
                        leaderboardSection
                    }
                    .padding(16)
                }
            }
        }
        .navigationTitle("Statistics")
    }

    private var lifetimeStatsCard: some View {
        let repo = viewModel.gameResultRepository
        return VStack(alignment: .leading, spacing: 8) {
            Text("Lifetime")
                .font(.headline)
            StatRow(label: "Games played", value: "\(repo.results.count)")
            StatRow(label: "Average moves", value: repo.averageMoves().map { String(format: "%.1f", $0) } ?? "-")
            StatRow(label: "Win streak", value: "\(repo.currentStreak())")
            let avgAcc = results.map(\.accuracyPercent).reduce(0, +) / max(results.count, 1)
            StatRow(label: "Average accuracy", value: "\(avgAcc)%")
            let avgTime = results.map(\.durationSeconds).reduce(0, +) / max(results.count, 1)
            StatRow(label: "Average time", value: formatDuration(avgTime))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var lastGameCard: some View {
        let result = results.last!
        let title = result.gameSetTitle.isEmpty ? "Game \(result.gameSetIndex + 1)" : result.gameSetTitle
        return VStack(alignment: .leading, spacing: 8) {
            Text("Last Game")
                .font(.headline)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            StatRow(label: "Moves", value: "\(result.moves)")
            StatRow(label: "Time", value: formatDuration(result.durationSeconds))
            StatRow(label: "Accuracy", value: "\(result.accuracyPercent)%")
            StarRatingView(stars: result.stars)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var leaderboardSection: some View {
        let gameSetIndices = Array(Set(results.map(\.gameSetIndex))).sorted()
        return VStack(alignment: .leading, spacing: 8) {
            Text("Best Scores Per Game")
                .font(.headline)

            ForEach(gameSetIndices, id: \.self) { gameSetIndex in
                let gameSet = viewModel.gameSets[safe: gameSetIndex]
                let title = gameSet?.title.isEmpty == false ? gameSet!.title : "Game \(gameSetIndex + 1)"
                let repo = viewModel.gameResultRepository
                let topResults = repo.topResults(gameSetIndex, limit: 5)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(.subheadline)
                            .fontWeight(.bold)
                        Spacer()
                        if let first = topResults.first {
                            StarRatingView(stars: first.stars)
                        }
                    }
                    StatRow(label: "Best moves", value: repo.bestMoves(gameSetIndex).map(String.init) ?? "-")
                    StatRow(label: "Best time", value: repo.bestTime(gameSetIndex).map { formatDuration($0) } ?? "-")
                    StatRow(label: "Games played", value: "\(repo.resultsForGameSet(gameSetIndex).count)")

                    if topResults.count > 1 {
                        Divider()
                        Text("Top \(topResults.count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        ForEach(Array(topResults.enumerated()), id: \.element.id) { i, r in
                            HStack {
                                Text("\(i + 1).")
                                    .fontWeight(.bold)
                                Text("\(r.moves) moves")
                                Spacer()
                                Text(formatDuration(r.durationSeconds))
                                Text("\(r.accuracyPercent)%")
                                    .frame(width: 40, alignment: .trailing)
                                StarRatingView(stars: r.stars, size: 12)
                            }
                            .font(.caption)
                        }
                    }
                }
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

private struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .fontWeight(.bold)
        }
    }
}

struct StarRatingView: View {
    let stars: Int
    var size: CGFloat = 16

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<3, id: \.self) { i in
                Image(systemName: i < stars ? "star.fill" : "star")
                    .font(.system(size: size))
                    .foregroundStyle(i < stars ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
            }
        }
    }
}

func formatDuration(_ seconds: Int) -> String {
    let mins = seconds / 60
    let secs = seconds % 60
    if mins > 0 {
        return "\(mins)m \(secs)s"
    }
    return "\(secs)s"
}
