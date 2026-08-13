import UIKit
import WebKit

final class ViewController: UIViewController {

    private var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black

        createWebView()
        loadBoomMusic()
    }

    private func createWebView() {

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

        webView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(
                equalTo: view.topAnchor
            ),
            webView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),
            webView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            webView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            )
        ])

        webView.scrollView.bounces = false
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
    }

    private func loadBoomMusic() {

        guard let wwwURL = Bundle.main.url(
            forResource: "www",
            withExtension: nil
        ) else {

            print("Boom Music: www tidak ditemukan")
            return
        }

        let indexURL = wwwURL.appendingPathComponent(
            "index.html"
        )

        guard FileManager.default.fileExists(
            atPath: indexURL.path
        ) else {

            print("Boom Music: index.html tidak ditemukan")
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

    override var supportedInterfaceOrientations:
        UIInterfaceOrientationMask {

        return .all
    }
}
