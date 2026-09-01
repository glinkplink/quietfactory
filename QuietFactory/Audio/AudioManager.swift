import AudioToolbox
import Foundation

enum AudioManager {
    static func playValidTap() {
        AudioServicesPlaySystemSound(1104)
    }

    static func playBlocked() {
        AudioServicesPlaySystemSound(1053)
    }

    static func playRelease() {
        AudioServicesPlaySystemSound(1306)
    }

    static func playConveyorLanding() {
        AudioServicesPlaySystemSound(1105)
    }

    static func playMatch() {
        AudioServicesPlaySystemSound(1110)
    }

    static func playWin() {
        AudioServicesPlaySystemSound(1025)
    }

    static func playStuck() {
        AudioServicesPlaySystemSound(1073)
    }
}
