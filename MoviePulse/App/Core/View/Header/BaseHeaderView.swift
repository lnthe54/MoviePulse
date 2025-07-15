import UIKit
import RxCocoa
import RxSwift
import RxGesture

protocol BaseHeaderViewDelegate: NSObjectProtocol {
    func actionSearch()
    func actionBack()
    func actionClose()
    func actionShare()
    func actionDelete()
}

class BaseHeaderView: UIView {

    // MARK: - IBOutlet
    @IBOutlet private weak var singleView: UIView!
    @IBOutlet private weak var multiView: UIView!
    @IBOutlet private weak var rightContentView: UIView!
    @IBOutlet private weak var searchView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var singleLabel: UILabel!
    @IBOutlet private weak var detailView: UIView!
    @IBOutlet private weak var detailTitle: UILabel!
    @IBOutlet private weak var backView: UIView!
    @IBOutlet private weak var shareView: UIView!
    @IBOutlet private weak var delView: UIView!

    // MARK: - Property
    private static let nibName: String = "BaseHeaderView"
    private let disposeBag = DisposeBag()
    private var topConstraint: NSLayoutConstraint!
    private var heightConstraint: NSLayoutConstraint!
            
    weak var delegate: BaseHeaderViewDelegate?
    
    class func instanceFromNib() -> BaseHeaderView {
        return UINib(nibName: nibName, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! BaseHeaderView
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func moveTo(parentViewController: UIViewController) {
        _ = self.then {
            $0.removeFromSuperview()
        }
        parentViewController.view.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false

        _ = parentViewController.view.then {
            // Constraint - Top
            self.topConstraint = NSLayoutConstraint(item: self,
                                                    attribute: .top,
                                                    relatedBy: .equal,
                                                    toItem: parentViewController.topLayoutGuide,
                                                    attribute: .bottom,
                                                    multiplier: 1,
                                                    constant: 0)
            $0.addConstraint(self.topConstraint)

            // Constraint - Right
            $0.addConstraint(NSLayoutConstraint(item: self,
                                                attribute: .trailing,
                                                relatedBy: .equal,
                                                toItem: parentViewController.view,
                                                attribute: .trailing,
                                                multiplier: 1,
                                                constant: 0))
            // Constraint - Left
            $0.addConstraint(NSLayoutConstraint(item: self,
                                                attribute: .leading,
                                                relatedBy: .equal,
                                                toItem: parentViewController.view,
                                                attribute: .leading,
                                                multiplier: 1,
                                                constant: 0))
            
            // Constraint - Height
            self.heightConstraint = NSLayoutConstraint(item: self,
                                                       attribute: .height,
                                                       relatedBy: .equal,
                                                       toItem: nil,
                                                       attribute: .notAnAttribute,
                                                       multiplier: 1,
                                                       constant: Constants.HEIGHT_NAV)
            $0.addConstraint(self.heightConstraint)
            
            $0.bringSubviewToFront(self)
        }
    }
    
    // MARK: - IBActions
    @objc
    private func didToSearch() {
        delegate?.actionSearch()
    }
    
    @IBAction func didToClose() {
        delegate?.actionClose()
    }
    
    @objc
    private func didToBack() {
        delegate?.actionBack()
    }
    
    @objc
    private func didToShare() {
        delegate?.actionShare()
    }
    
    @objc
    private func didToDelete() {
        delegate?.actionDelete()
    }
}

extension BaseHeaderView {
    func setupHeader(withType type: HeaderViewType) {
        backgroundColor = .clear
        
        switch type {
        case .single(let title):
            setupSingleView(title: title)
            singleView.isHidden = false
            multiView.isHidden = true
            detailView.isHidden = true
        case .multi(let title, let buttons):
            setupMultiView(title: title, buttons: buttons)
            singleView.isHidden = true
            multiView.isHidden = false
            detailView.isHidden = true
        case .detail(let title, let buttons):
            setupDetailView(title: title, buttons: buttons)
            singleView.isHidden = true
            multiView.isHidden = true
            detailView.isHidden = false
        }
    }
    
    private func setupSingleView(title: String) {
        singleLabel.text = title
        singleLabel.textColor = UIColor(hexString: "#252934")
        singleLabel.font = .outfitFont(ofSize: 20, weight: .semiBold)
    }
    
    private func setupMultiView(title: String, buttons: [RightContentType]) {
        titleLabel.text = title
        titleLabel.textColor = UIColor(hexString: "#252934")
        titleLabel.font = .outfitFont(ofSize: 20, weight: .semiBold)
        
        searchView.corner(4)
        searchView.backgroundColor = .pimaryColor
        let tapToSearch = UITapGestureRecognizer(target: self, action: #selector(didToSearch))
        searchView.isUserInteractionEnabled = true
        searchView.addGestureRecognizer(tapToSearch)
    }
    
    private func setupDetailView(title: String, buttons: [RightContentType]) {
        detailTitle.text = title
        detailTitle.textColor = UIColor(hexString: "#252934")
        detailTitle.font = .outfitFont(ofSize: 20, weight: .semiBold)
        backView.corner(4)
        backView.backgroundColor = UIColor(hexString: "#E7D9FB")
        let tapToBackView = UITapGestureRecognizer(target: self, action: #selector(didToBack))
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(tapToBackView)
        
        shareView.backgroundColor = UIColor(hexString: "#E7D9FB")
        let tapToShare = UITapGestureRecognizer(target: self, action: #selector(didToShare))
        shareView.isUserInteractionEnabled = true
        shareView.addGestureRecognizer(tapToShare)
        shareView.corner(4)
        
        delView.backgroundColor = UIColor(hexString: "#E7D9FB")
        delView.corner(4)
        let tapToDelete = UITapGestureRecognizer(target: self, action: #selector(didToDelete))
        delView.isUserInteractionEnabled = true
        delView.addGestureRecognizer(tapToDelete)
        
        if buttons.isEmpty {
            shareView.isHidden = true
            delView.isHidden = true
        } else {
            shareView.isHidden = !buttons.contains(where: { $0 == .share })
            delView.isHidden = !buttons.contains(where: { $0 == .delete })
        }
    }
}

enum HeaderViewType {
    case single(title: String)
    case multi(title: String, rightContents: [RightContentType] = [])
    case detail(title: String, rightContents: [RightContentType] = [])
}

enum RightContentType {
    case search
    case save
    case delete
    case share
}
