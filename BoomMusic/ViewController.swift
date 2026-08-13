import UIKit
import WebKit

class ViewController: UIViewController,
                      WKScriptMessageHandler,
                      WKNavigationDelegate {

    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupWebView()
        loadWebContent()
    }

    private func setupWebView() {

        let config = WKWebViewConfiguration()

        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        config.userContentController.add(
            self,
            name: "boomBridge"
        )

        webView = WKWebView(
            frame: view.bounds,
            configuration: config
        )

        webView.autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight
        ]

        webView.navigationDelegate = self
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never

        view.addSubview(webView)

        AudioManager.shared.webView = webView
    }

    private func loadWebContent() {

        guard let indexURL = Bundle.main.url(
            forResource: "index",
            withExtension: "html",
            subdirectory: "www"
        ) else {
            print("ERROR: www/index.html tidak ditemukan")
            return
        }

        webView.loadFileURL(
            indexURL,
            allowingReadAccessTo: indexURL.deletingLastPathComponent()
        )
    }

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {

        guard message.name == "boomBridge",
              let data = message.body as? [String: Any]
        else {
            return
        }

        guard data["action"] as? String == "updateNowPlaying"
        else {
            return
        }

        let title =
            data["title"] as? String ?? "Boom Music"

        let artist =
            data["artist"] as? String ?? "Unknown Artist"

        let duration =
            data["duration"] as? Double ?? 0

        let currentTime =
            data["currentTime"] as? Double ?? 0

        let isPlaying =
            data["isPlaying"] as? Bool ?? false

        AudioManager.shared.updateNowPlaying(
            title: title,
            artist: artist,
            duration: duration,
            currentTime: currentTime,
            isPlaying: isPlaying
        )
    }

    deinit {
        webView?.configuration.userContentController.removeScriptMessageHandler(
            forName: "boomBridge"
        )
    }
}
