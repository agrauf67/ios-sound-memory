import SwiftUI

struct HowToPlayScreen: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionHeader(title: "Goal")
                Text("Find all 12 matching pairs of cards. Cards are matched by their sound \u{2014} tap a card to hear it, then find the card that sounds the same!")

                SectionHeader(title: "How to Play")

                StepItemView(icon: "hand.tap", title: "1. Tap a card",
                    description: "Tap any face-down card to flip it. Depending on the game mode, you will hear the word spoken aloud, see an image, or both.")

                StepItemView(icon: "ear", title: "2. Tap a second card",
                    description: "Tap another face-down card. Listen carefully \u{2014} does it sound the same as the first card?")

                StepItemView(icon: "star", title: "3. Match or try again",
                    description: "If the two cards match, they stay face-up. If not, they flip back after a short delay. Try to remember where each sound is!")

                SectionHeader(title: "Game Modes")

                StepItemView(icon: "speaker.wave.2", title: "Speech only",
                    description: "Cards are identified only by their spoken word. This is the classic Sound Memory mode.")

                StepItemView(icon: "photo", title: "Image only",
                    description: "Cards show an image when flipped. No speech is played.")

                StepItemView(icon: "speaker.wave.2", title: "Speech + Image",
                    description: "Cards play the spoken word and show the image when flipped.")

                SectionHeader(title: "Scoring")
                Text("Your score is based on the number of moves (pairs of cards flipped):")
                Text("12 moves or fewer = 3 stars").fontWeight(.bold)
                Text("13\u{2013}18 moves = 2 stars").fontWeight(.bold)
                Text("19+ moves = 1 star").fontWeight(.bold)

                SectionHeader(title: "Tips")
                Text("Use Settings to change the language, game mode, card display time, and whether to use official or colloquial pronunciation.")
            }
            .padding(16)
        }
        .navigationTitle("How to Play")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
            }
        }
    }
}

private struct SectionHeader: View {
    let title: LocalizedStringKey
    var body: some View {
        Text(title)
            .font(.title3)
            .fontWeight(.bold)
            .foregroundStyle(.tint)
    }
}

private struct StepItemView: View {
    let icon: String
    let title: LocalizedStringKey
    let description: LocalizedStringKey

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.tint)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).fontWeight(.bold)
                Text(description)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
