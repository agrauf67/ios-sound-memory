import SwiftUI

struct ContentView: View {
    @State private var viewModel = SoundMemoryViewModel()
    @State private var selectedTab = 1
    @State private var showWalkthrough = false
    @State private var showSettings = false
    @State private var showHowToPlay = false
    @State private var showHelp = false
    @State private var showAbout = false
    @State private var showStore = false

    private var appLocale: Locale {
        let lang = viewModel.settings.language.components(separatedBy: "-").first ?? "en"
        return Locale(identifier: lang)
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Games", systemImage: "square.grid.3x3", value: 0) {
                NavigationStack {
                    LevelsScreen(viewModel: viewModel) { gameIndex in
                        viewModel.selectGame(gameIndex)
                        selectedTab = 1
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            appMenuButton
                        }
                    }
                }
            }

            Tab("Play", systemImage: "play.fill", value: 1) {
                NavigationStack {
                    PlayScreen(viewModel: viewModel)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                appMenuButton
                            }
                        }
                }
            }

            Tab("Stats", systemImage: "chart.bar", value: 2) {
                NavigationStack {
                    StatsScreen(viewModel: viewModel)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                appMenuButton
                            }
                        }
                }
            }
        }
        .id(viewModel.settings.language)
        .tint(viewModel.settings.accentColor)
        .preferredColorScheme(viewModel.settings.preferredColorScheme)
        .environment(\.locale, appLocale)
        .fullScreenCover(isPresented: $showWalkthrough) {
            WalkthroughScreen(viewModel: viewModel) {
                showWalkthrough = false
            }
            .environment(\.locale, appLocale)
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                SettingsScreen(viewModel: viewModel) {
                    showWalkthrough = true
                }
            }
            .tint(viewModel.settings.accentColor)
            .preferredColorScheme(viewModel.settings.preferredColorScheme)
            .environment(\.locale, appLocale)
        }
        .sheet(isPresented: $showHowToPlay) {
            NavigationStack { HowToPlayScreen() }
                .tint(viewModel.settings.accentColor)
                .environment(\.locale, appLocale)
        }
        .sheet(isPresented: $showHelp) {
            NavigationStack { HelpScreen() }
                .tint(viewModel.settings.accentColor)
                .environment(\.locale, appLocale)
        }
        .sheet(isPresented: $showAbout) {
            NavigationStack { AboutScreen() }
                .tint(viewModel.settings.accentColor)
                .environment(\.locale, appLocale)
        }
        .sheet(isPresented: $showStore) {
            NavigationStack {
                StoreScreen(storeManager: viewModel.storeManager)
            }
            .tint(viewModel.settings.accentColor)
            .preferredColorScheme(viewModel.settings.preferredColorScheme)
            .environment(\.locale, appLocale)
        }
        .onAppear {
            if !viewModel.settings.walkthroughCompleted {
                showWalkthrough = true
            }
        }
    }

    private var appMenuButton: some View {
        Menu {
            Button { showStore = true } label: {
                Label("Store", systemImage: "cart")
            }
            Button { showSettings = true } label: {
                Label("Settings", systemImage: "gear")
            }
            Button { showHowToPlay = true } label: {
                Label("How to Play", systemImage: "questionmark.circle")
            }
            Button { showHelp = true } label: {
                Label("Help", systemImage: "lifepreserver")
            }
            Button { showAbout = true } label: {
                Label("About", systemImage: "info.circle")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
}

#Preview {
    ContentView()
}
