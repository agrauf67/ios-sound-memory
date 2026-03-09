import AVFoundation

class TtsManager: NSObject, AVSpeechSynthesizerDelegate {
    nonisolated(unsafe) private let synthesizer = AVSpeechSynthesizer()
    var onSpeakingChanged: ((Bool) -> Void)?

    override init() {
        super.init()
        synthesizer.delegate = self
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func speak(_ text: String, language: String, gender: String = "female") {
        guard !text.isEmpty else { return }
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = findVoice(language: language, gender: gender)
        synthesizer.speak(utterance)
    }

    private func findVoice(language: String, gender: String) -> AVSpeechSynthesisVoice? {
        let targetGender: AVSpeechSynthesisVoiceGender = gender == "male" ? .male : .female
        let langPrefix = language.components(separatedBy: "-").first ?? language
        let allVoices = AVSpeechSynthesisVoice.speechVoices()

        // 1. Exact language + gender match, prefer higher quality
        let exactMatch = allVoices
            .filter { $0.language == language && $0.gender == targetGender }
            .sorted { $0.quality.rawValue > $1.quality.rawValue }
        if let voice = exactMatch.first { return voice }

        // 2. Same language prefix + gender (e.g. "de" matches "de-DE", "de-AT")
        let prefixMatch = allVoices
            .filter { $0.language.hasPrefix(langPrefix) && $0.gender == targetGender }
            .sorted { $0.quality.rawValue > $1.quality.rawValue }
        if let voice = prefixMatch.first { return voice }

        // 3. Fall back to default voice for language
        return AVSpeechSynthesisVoice(language: language)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        Task { @MainActor in
            onSpeakingChanged?(true)
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            onSpeakingChanged?(false)
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            onSpeakingChanged?(false)
        }
    }
}
