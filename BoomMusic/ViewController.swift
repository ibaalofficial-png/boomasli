import UIKit
import WebKit

final class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    private var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupWebView()
        loadLocalWebApp()
    }

    private func setupWebView() {

        let configuration = WKWebViewConfiguration()

        configuration.allowsInlineMediaPlayback = true

        if #available(iOS 10.0, *) {
            configuration.mediaTypesRequiringUserActionForPlayback = []
        }

        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true

        configuration.preferences = preferences

        webView = WKWebView(
            frame: .zero,
            configuration: configuration
        )

        webView.navigationDelegate = self
        webView.uiDelegate = self

        webView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        webView.allowsBackForwardNavigationGestures = false

        webView.scrollView.bounces = false
        webView.scrollView.alwaysBounceVertical = false
        webView.scrollView.alwaysBounceHorizontal = false
    }

    private func loadLocalWebApp() {

        guard let wwwURL = Bundle.main.url(
            forResource: "www",
            withExtension: nil
        ) else {

            print("ERROR: folder www tidak ditemukan di Bundle")

            return
        }

        let indexURL = wwwURL.appendingPathComponent("index.html")

        guard FileManager.default.fileExists(
            atPath: indexURL.path
        ) else {

            print("ERROR: index.html tidak ditemukan")

            return
        }

        webView.loadFileURL(
            indexURL,
            allowingReadAccessTo: wwwURL
        )
    }

    override var prefersStatusBarHidden: Bool {
        true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .all
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        true
    }
}
