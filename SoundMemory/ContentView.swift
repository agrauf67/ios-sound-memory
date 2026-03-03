import SwiftUI

enum Screen: String, CaseIterable, Identifiable {
    case play = "Play"
    case levels = "Levels"
    case stats = "Statistics"
    case settings = "Settings"
    case howToPlay = "How to Play"
    case about = "About"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .play: return "play.fill"
        case .levels: return "square.grid.2x2"
        case .stats: return "chart.bar.fill"
        case .settings: return "gearshape.fill"
        case .howToPlay: return "questionmark.circle.fill"
        case .about: return "info.circle.fill"
        }
    }

    var shortTitle: String {
        switch self {
        case .stats: return "Stats"
        default: return rawValue
        }
    }

    static var bottomTabs: [Screen] { [.play, .levels, .stats] }
    static var drawerItems: [Screen] { allCases }
}

struct ContentView: View {
    @StateObject private var viewModel = SoundMemoryViewModel()
    @State private var selectedTab: Screen = .play
    @State private var showSidebar = false

    /// True when the selected screen is not one of the bottom tabs.
    private var isNonTabScreen: Bool {
        !Screen.bottomTabs.contains(selectedTab)
    }

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                ForEach(Screen.bottomTabs) { screen in
                    screenView(for: screen)
                        .tabItem {
                            Label(screen.shortTitle, systemImage: screen.icon)
                        }
                        .tag(screen)
                }
            }
            .tint(.primaryLight)

            // Full-screen overlay for non-tab screens (Settings, How to Play, About)
            if isNonTabScreen {
                NavigationStack {
                    nonTabScreenView(for: selectedTab)
                }
            }

            // Sidebar overlay
            if showSidebar {
                SidebarMenu(
                    selectedScreen: $selectedTab,
                    isShowing: $showSidebar
                )
            }
        }
        .environmentObject(viewModel)
    }

    @ViewBuilder
    private func screenView(for screen: Screen) -> some View {
        NavigationStack {
            switch screen {
            case .play:
                PlayScreen(showSidebar: $showSidebar)
            case .levels:
                LevelsScreen(showSidebar: $showSidebar)
            case .stats:
                StatsScreen(showSidebar: $showSidebar)
            default:
                EmptyView()
            }
        }
    }

    @ViewBuilder
    private func nonTabScreenView(for screen: Screen) -> some View {
        switch screen {
        case .settings:
            SettingsScreen(onBack: { selectedTab = .play })
        case .howToPlay:
            HowToPlayScreen(onBack: { selectedTab = .play })
        case .about:
            AboutScreen(onBack: { selectedTab = .play })
        default:
            EmptyView()
        }
    }
}
