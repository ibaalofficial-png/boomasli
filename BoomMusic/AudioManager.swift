import Foundation
import AVFoundation
import MediaPlayer
import WebKit

final class AudioManager {

    static let shared = AudioManager()

    weak var webView: WKWebView?

    private init() {
        setupAudioSession()
        setupRemoteTransportControls()
        setupInterruptionObserver()
    }

    // MARK: - Audio Session

    func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()

            try session.setCategory(
                .playback,
                mode: .default,
                options: []
            )

            try session.setActive(true)

        } catch {
            print("AudioSession error:", error)
        }
    }

    // MARK: - Lock Screen / Control Center

    private func setupRemoteTransportControls() {

        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.isEnabled = true

        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.evaluateJavaScript("""
            if (window.Player && typeof window.Player.toggle === 'function') {
                if (window.Player.audio && window.Player.audio.paused) {
                    window.Player.toggle();
                }
            }
            """)
            return .success
        }

        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.evaluateJavaScript("""
            if (window.Player && typeof window.Player.toggle === 'function') {
                if (window.Player.audio && !window.Player.audio.paused) {
                    window.Player.toggle();
                }
            }
            """)
            return .success
        }

        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.evaluateJavaScript("""
            if (window.Player && typeof window.Player.next === 'function') {
                window.Player.next();
            }
            """)
            return .success
        }

        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.evaluateJavaScript("""
            if (window.Player && typeof window.Player.prev === 'function') {
                window.Player.prev();
            }
            """)
            return .success
        }
    }

    // MARK: - Now Playing

    func updateNowPlaying(
        title: String,
        artist: String,
        duration: Double,
        currentTime: Double,
        isPlaying: Bool
    ) {

        var info: [String: Any] = [:]

        info[MPMediaItemPropertyTitle] = title
        info[MPMediaItemPropertyArtist] = artist

        if duration > 0 {
            info[MPMediaItemPropertyPlaybackDuration] = duration
        }

        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime

        info[MPNowPlayingInfoPropertyPlaybackRate] =
            isPlaying ? 1.0 : 0.0

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    // MARK: - Audio Interruption

    private func setupInterruptionObserver() {

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )
    }

    @objc private func handleInterruption(
        notification: Notification
    ) {

        guard
            let userInfo = notification.userInfo,
            let rawType =
                userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type =
                AVAudioSession.InterruptionType(rawValue: rawType)
        else {
            return
        }

        switch type {

        case .began:

            evaluateJavaScript("""
            if (window.Player &&
                window.Player.audio &&
                !window.Player.audio.paused) {
                window.Player.audio.pause();
            }
            """)

        case .ended:

            guard
                let rawOptions =
                    userInfo[AVAudioSessionInterruptionOptionKey] as? UInt
            else {
                return
            }

            let options =
                AVAudioSession.InterruptionOptions(
                    rawValue: rawOptions
                )

            if options.contains(.shouldResume) {

                evaluateJavaScript("""
                if (window.Player &&
                    window.Player.audio &&
                    window.Player.audio.paused) {
                    window.Player.audio.play();
                }
                """)
            }

        @unknown default:
            break
        }
    }

    // MARK: - JavaScript Bridge

    private func evaluateJavaScript(_ script: String) {

        DispatchQueue.main.async { [weak self] in

            guard let webView = self?.webView else {
                return
            }

            webView.evaluateJavaScript(
                script,
                completionHandler: nil
            )
        }
    }

    deinit {

        NotificationCenter.default.removeObserver(self)

        MPRemoteCommandCenter.shared()
            .playCommand
            .removeTarget(nil)

        MPRemoteCommandCenter.shared()
            .pauseCommand
            .removeTarget(nil)

        MPRemoteCommandCenter.shared()
            .nextTrackCommand
            .removeTarget(nil)

        MPRemoteCommandCenter.shared()
            .previousTrackCommand
            .removeTarget(nil)
    }
}
