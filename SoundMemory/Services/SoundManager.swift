import AVFoundation

class SoundManager {

    private var audioPlayers: [String: AVAudioPlayer] = [:]

    func playSound(named name: String, volume: Float = 1.0) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = volume
            player.play()
            audioPlayers[name] = player
        } catch {
            print("Error playing sound: \(error)")
        }
    }

    func release() {
        audioPlayers.values.forEach { $0.stop() }
        audioPlayers.removeAll()
    }
}
