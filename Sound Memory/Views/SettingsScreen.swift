import SwiftUI

struct SettingsScreen: View {
    let viewModel: SoundMemoryViewModel
    var onShowWalkthrough: (() -> Void)?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var settings = viewModel.settings

        Form {
            Section("Design") {
                Picker("Theme", selection: $settings.themeMode) {
                    Text("System").tag("system")
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                }

                Picker("Color Scheme", selection: $settings.colorTheme) {
                    Label("Blue", systemImage: "circle.fill").foregroundStyle(.blue).tag("blue")
                    Label("Green", systemImage: "circle.fill").foregroundStyle(.green).tag("green")
                    Label("Purple", systemImage: "circle.fill").foregroundStyle(.purple).tag("purple")
                    Label("Orange", systemImage: "circle.fill").foregroundStyle(.orange).tag("orange")
                    Label("Red", systemImage: "circle.fill").foregroundStyle(.red).tag("red")
                    Label("Teal", systemImage: "circle.fill").foregroundStyle(.teal).tag("teal")
                    Label("Pink", systemImage: "circle.fill").foregroundStyle(.pink).tag("pink")
                    Label("Grey", systemImage: "circle.fill").foregroundStyle(.gray).tag("grey")
                }
            }

            Section("Language") {
                Picker("Language", selection: $settings.language) {
                    Text("Deutsch").tag("de-DE")
                    Text("English").tag("en-US")
                    Text("Français").tag("fr-FR")
                    Text("Español").tag("es-ES")
                }
            }

            Section("Game Mode") {
                Picker("Mode", selection: $settings.gameMode) {
                    Text("Speech only").tag(1)
                    Text("Image only").tag(2)
                    Text("Speech + Image").tag(3)
                }
            }

            Section("Timing") {
                VStack(alignment: .leading) {
                    Text("Card display time: \(settings.cardDisplaySeconds)s")
                    Slider(value: Binding(
                        get: { Double(settings.cardDisplaySeconds) },
                        set: { settings.cardDisplaySeconds = Int($0) }
                    ), in: 1...5, step: 1)
                }

                VStack(alignment: .leading) {
                    Text("New game delay: \(settings.gameCompleteSeconds)s")
                    Slider(value: Binding(
                        get: { Double(settings.gameCompleteSeconds) },
                        set: { settings.gameCompleteSeconds = Int($0) }
                    ), in: 1...10, step: 1)
                }
            }

            Section("Speech") {
                Toggle(isOn: $settings.useOfficialText) {
                    VStack(alignment: .leading) {
                        Text("Speech text")
                        Text(settings.useOfficialText ? "Official" : "Colloquial")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if let onShowWalkthrough {
                Section {
                    Button {
                        dismiss()
                        onShowWalkthrough()
                    } label: {
                        Label("Show Walkthrough", systemImage: "hand.wave")
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
            }
        }
    }
}
