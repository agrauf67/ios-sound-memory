import SwiftUI

struct HelpScreen: View {
    @Environment(\.dismiss) private var dismiss

    private let faqItems: [(String, String)] = [
        ("How do I play Sound Memory?",
         "Tap cards to flip them and hear a word. Find the matching pair by listening for the same sound. Match all 12 pairs to win!"),
        ("What game modes are available?",
         "There are 3 modes: Speech only (hear words), Image only (see pictures), and Speech + Image (both). Change the mode in Settings."),
        ("How does scoring work?",
         "Your score is based on the number of moves (pairs flipped). 12 or fewer = 3 stars, 13\u{2013}18 = 2 stars, 19+ = 1 star."),
        ("Which languages are supported?",
         "Sound Memory includes game sets in German, English, French, and Spanish. Each set uses native Text-to-Speech pronunciation."),
        ("Why can't I hear any speech?",
         "Make sure your device volume is turned up and the game mode is set to \"Speech only\" or \"Speech + Image\" in Settings."),
        ("What can I change in Settings?",
         "You can change the app language, game mode, card display time, new game delay, and switch between official and colloquial pronunciation."),
        ("What do the statistics show?",
         "Statistics track your lifetime performance including games played, average moves, win streak, accuracy, and best scores per game with star ratings."),
        ("How do I restart a game?",
         "Tap the restart icon (circular arrow) in the top bar of the play screen to shuffle and restart the current game.")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Frequently Asked Questions")
                    .font(.headline)
                    .padding(.bottom, 12)
                    .padding(.horizontal, 16)

                ForEach(Array(faqItems.enumerated()), id: \.offset) { _, item in
                    FaqItemView(question: item.0, answer: item.1)
                }

                Divider()
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)

                Text("Contact Us")
                    .font(.headline)
                    .padding(.bottom, 12)
                    .padding(.horizontal, 16)

                Button {
                    if let url = URL(string: "mailto:agrauf67@gmail.com?subject=Sound%20Memory%20-%20Feedback") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "envelope")
                            .foregroundStyle(.tint)
                        VStack(alignment: .leading) {
                            Text("Send feedback via email")
                                .foregroundStyle(.tint)
                            Text("Report bugs, request features, or ask questions")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)

                Button {
                    if let url = URL(string: "https://apps.apple.com/app/id0000000000") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "star")
                            .foregroundStyle(.tint)
                        VStack(alignment: .leading) {
                            Text("Rate on App Store")
                                .foregroundStyle(.tint)
                            Text("Your rating helps others find the app")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)

                Spacer().frame(height: 24)
            }
            .padding(.top, 8)
        }
        .navigationTitle("Help & Support")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
            }
        }
    }
}

private struct FaqItemView: View {
    let question: String
    let answer: String
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(question)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
            .buttonStyle(.plain)

            if isExpanded {
                Text(answer)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 10)
            }

            Divider()
                .padding(.horizontal, 16)
        }
    }
}
