import SwiftUI

struct ContentView: View {
    @State private var viewModel = SoundMemoryViewModel()
    @State private var selectedTab = 1
    @State private var showWalkthrough = false
    @State private var showSettings = false
    @State private var showHowToPlay = false
    @State private var showHelp = false
    @State private var showAbout = false

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
        .tint(viewModel.settings.accentColor)
        .preferredColorScheme(viewModel.settings.preferredColorScheme)
        .fullScreenCover(isPresented: $showWalkthrough) {
            WalkthroughScreen(viewModel: viewModel) {
                showWalkthrough = false
            }
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                SettingsScreen(viewModel: viewModel) {
                    showWalkthrough = true
                }
            }
            .tint(viewModel.settings.accentColor)
            .preferredColorScheme(viewModel.settings.preferredColorScheme)
        }
        .sheet(isPresented: $showHowToPlay) {
            NavigationStack { HowToPlayScreen() }
                .tint(viewModel.settings.accentColor)
        }
        .sheet(isPresented: $showHelp) {
            NavigationStack { HelpScreen() }
                .tint(viewModel.settings.accentColor)
        }
        .sheet(isPresented: $showAbout) {
            NavigationStack { AboutScreen() }
                .tint(viewModel.settings.accentColor)
        }
        .onAppear {
            if !viewModel.settings.walkthroughCompleted {
                showWalkthrough = true
            }
        }
    }

    private var appMenuButton: some View {
        Menu {
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
