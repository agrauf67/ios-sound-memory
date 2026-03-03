import Foundation

class SettingsManager: ObservableObject {

    private enum Keys {
        static let soundEnabled = "sound_enabled"
        static let volume = "volume"
    }

    @Published var soundEnabled: Bool {
        didSet { UserDefaults.standard.set(soundEnabled, forKey: Keys.soundEnabled) }
    }

    @Published var volume: Float {
        didSet { UserDefaults.standard.set(volume, forKey: Keys.volume) }
    }

    init() {
        let defaults = UserDefaults.standard

        if defaults.object(forKey: Keys.soundEnabled) == nil {
            defaults.set(true, forKey: Keys.soundEnabled)
        }
        if defaults.object(forKey: Keys.volume) == nil {
            defaults.set(Float(1.0), forKey: Keys.volume)
        }

        self.soundEnabled = defaults.bool(forKey: Keys.soundEnabled)
        self.volume = defaults.float(forKey: Keys.volume)
    }
}
