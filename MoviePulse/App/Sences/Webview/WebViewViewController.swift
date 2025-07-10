import UIKit
import WebKit

class WebViewViewController: BaseViewController {
    
    init(title: String, url: String) {
        self.titleScreen = title
        self.url = url
        super.init(nibName: Self.className, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - IBOutlets
    @IBOutlet private weak var topConstraint: NSLayoutConstraint!
    @IBOutlet private weak var containerView: UIView!
    
    // MARK: - Properties
    private var titleScreen: String
    private var url: String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        LoadingView.shared.startLoading()
        
        if let myURL = URL(string: url) {
            loadRequest(myURL)
        }
        
        NotificationCenter.default.post(name: .hideTabBar, object: nil)
    }
    
    override func setupViews() {
        topConstraint.constant = Constants.HEIGHT_NAV
        setupHeader(withType: .detail(title: titleScreen))
    }
    
    override func actionBack() {
        navigationController?.popViewController(animated: true)
    }
    
    private func loadRequest(_ url: URL) {
        let webView = WKWebView(frame: CGRect(x: 0,
                                              y: 0,
                                              width: UIScreen.main.bounds.width,
                                              height: containerView.frame.height),
                                configuration: WKWebViewConfiguration())
        webView.navigationDelegate = self
        
        containerView.addSubview(webView)
        
        let myRequest = URLRequest(url: url)
        webView.load(myRequest)
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        LoadingView.shared.endLoading()
    }
}
