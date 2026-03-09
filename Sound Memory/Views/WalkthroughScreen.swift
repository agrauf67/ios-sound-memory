import SwiftUI

struct WalkthroughScreen: View {
    let viewModel: SoundMemoryViewModel
    let onComplete: () -> Void

    @State private var currentPage = 0
    private let totalPages = 5

    private let pages: [(title: String, description: String, tips: [String])] = [
        ("Welcome to Sound Memory",
         "A memory card game where you match pairs by listening to sounds instead of looking at pictures!",
         ["Match cards by their spoken word",
          "Train your memory and learn new vocabulary",
          "Works completely offline \u{2014} no account required"]),
        ("How to Play",
         "Tap cards to hear words spoken aloud. Find the matching pair by listening for the same sound.",
         ["Tap a card to flip it and hear the word",
          "Tap a second card \u{2014} do they sound the same?",
          "Find all 12 pairs to win the game"]),
        ("4 Languages",
         "Play game sets in German, English, French, and Spanish. Each set uses native Text-to-Speech pronunciation.",
         ["Game sets with native pronunciation per language",
          "Learn words across multiple languages",
          "Change the app language anytime in Settings"]),
        ("Game Modes & Settings",
         "Choose how you want to play and customize the experience to your liking.",
         ["Speech only, Image only, or Speech + Image",
          "Adjust card display time and pronunciation style",
          "Pick your favorite color theme and dark mode"]),
        ("Ready to Play!",
         "Select a game set and start matching cards. Track your progress with detailed statistics and star ratings.",
         ["Choose a game under \"Games\" to get started",
          "Track moves, accuracy, and time per game",
          "Earn up to 3 stars per game \u{2014} aim for 12 moves!"])
    ]

    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(0..<totalPages, id: \.self) { index in
                    WalkthroughPageView(
                        title: pages[index].title,
                        description: pages[index].description,
                        tips: pages[index].tips
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            VStack(spacing: 16) {
                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.accentColor : Color.secondary.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }

                // Buttons
                HStack {
                    if currentPage < totalPages - 1 {
                        Button("Skip") {
                            withAnimation {
                                currentPage = totalPages - 1
                            }
                        }
                        .foregroundStyle(.secondary)
                    } else {
                        Spacer().frame(width: 60)
                    }

                    Spacer()

                    Button {
                        if currentPage < totalPages - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            viewModel.settings.walkthroughCompleted = true
                            onComplete()
                        }
                    } label: {
                        Text(currentPage < totalPages - 1 ? "Next" : "Get Started")
                            .fontWeight(.semibold)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 32)
        }
        .background(Color(.systemBackground))
    }
}

private struct WalkthroughPageView: View {
    let title: String
    let description: String
    let tips: [String]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer().frame(height: 40)

                Image(systemName: "speaker.wave.2.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.tint)

                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(description)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(tips, id: \.self) { tip in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark")
                                .font(.caption)
                                .foregroundStyle(.tint)
                                .padding(.top, 2)
                            Text(tip)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 32)
            }
            .padding(32)
        }
    }
}
