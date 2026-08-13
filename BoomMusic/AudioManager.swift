import Foundation
import AVFoundation
import MediaPlayer

final class AudioManager {

    static let shared = AudioManager()

    private let audioSession = AVAudioSession.sharedInstance()

    private init() {}

    func configure() {

        do {

            try audioSession.setCategory(
                .playback,
                mode: .default,
                options: [
                    .allowAirPlay,
                    .allowBluetooth,
                    .allowBluetoothA2DP
                ]
            )

            try audioSession.setActive(true)

            setupRemoteCommands()

            print("BoomMusic AudioManager: READY")

        } catch {

            print(
                "BoomMusic AudioManager ERROR:",
                error.localizedDescription
            )
        }
    }

    private func setupRemoteCommands() {

        let center = MPRemoteCommandCenter.shared()

        center.playCommand.isEnabled = true
        center.pauseCommand.isEnabled = true
        center.nextTrackCommand.isEnabled = true
        center.previousTrackCommand.isEnabled = true

        center.playCommand.addTarget { _ in

            NotificationCenter.default.post(
                name: .boomMusicPlay,
                object: nil
            )

            return .success
        }

        center.pauseCommand.addTarget { _ in

            NotificationCenter.default.post(
                name: .boomMusicPause,
                object: nil
            )

            return .success
        }

        center.nextTrackCommand.addTarget { _ in

            NotificationCenter.default.post(
                name: .boomMusicNext,
                object: nil
            )

            return .success
        }

        center.previousTrackCommand.addTarget { _ in

            NotificationCenter.default.post(
                name: .boomMusicPrevious,
                object: nil
            )

            return .success
        }
    }
}

extension Notification.Name {

    static let boomMusicPlay =
        Notification.Name("BoomMusic.Play")

    static let boomMusicPause =
        Notification.Name("BoomMusic.Pause")

    static let boomMusicNext =
        Notification.Name("BoomMusic.Next")

    static let boomMusicPrevious =
        Notification.Name("BoomMusic.Previous")
}
