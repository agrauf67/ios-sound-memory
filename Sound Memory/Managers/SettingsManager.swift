import SwiftUI

@Observable
class SettingsManager {
    var gameMode: Int {
        didSet { UserDefaults.standard.set(gameMode, forKey: "gameMode") }
    }
    var language: String {
        didSet { UserDefaults.standard.set(language, forKey: "language") }
    }
    var cardDisplaySeconds: Int {
        didSet { UserDefaults.standard.set(cardDisplaySeconds, forKey: "cardDisplaySeconds") }
    }
    var gameCompleteSeconds: Int {
        didSet { UserDefaults.standard.set(gameCompleteSeconds, forKey: "gameCompleteSeconds") }
    }
    var useOfficialText: Bool {
        didSet { UserDefaults.standard.set(useOfficialText, forKey: "useOfficialText") }
    }
    var voiceGender: String {
        didSet { UserDefaults.standard.set(voiceGender, forKey: "voiceGender") }
    }
    var themeMode: String {
        didSet { UserDefaults.standard.set(themeMode, forKey: "themeMode") }
    }
    var colorTheme: String {
        didSet { UserDefaults.standard.set(colorTheme, forKey: "colorTheme") }
    }
    var walkthroughCompleted: Bool {
        didSet { UserDefaults.standard.set(walkthroughCompleted, forKey: "walkthroughCompleted") }
    }

    var preferredColorScheme: ColorScheme? {
        switch themeMode {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    var accentColor: Color {
        switch colorTheme {
        case "green": return .green
        case "purple": return .purple
        case "orange": return .orange
        case "red": return .red
        case "teal": return .teal
        case "pink": return .pink
        case "grey": return .gray
        default: return .blue
        }
    }

    init() {
        let ud = UserDefaults.standard
        ud.register(defaults: [
            "gameMode": 1,
            "language": "en-US",
            "cardDisplaySeconds": 1,
            "gameCompleteSeconds": 3,
            "useOfficialText": false,
            "voiceGender": "female",
            "themeMode": "system",
            "colorTheme": "blue",
            "walkthroughCompleted": false
        ])
        gameMode = ud.integer(forKey: "gameMode")
        language = ud.string(forKey: "language") ?? "en-US"
        cardDisplaySeconds = ud.integer(forKey: "cardDisplaySeconds")
        gameCompleteSeconds = ud.integer(forKey: "gameCompleteSeconds")
        useOfficialText = ud.bool(forKey: "useOfficialText")
        voiceGender = ud.string(forKey: "voiceGender") ?? "female"
        themeMode = ud.string(forKey: "themeMode") ?? "system"
        colorTheme = ud.string(forKey: "colorTheme") ?? "blue"
        walkthroughCompleted = ud.bool(forKey: "walkthroughCompleted")
    }
}
