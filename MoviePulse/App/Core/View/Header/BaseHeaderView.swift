import UIKit
import RxCocoa
import RxSwift
import RxGesture

protocol BaseHeaderViewDelegate: NSObjectProtocol {
    func actionFavorite()
    func actionSearch()
    func actionBack()
    func actionClose()
}

class BaseHeaderView: UIView {

    // MARK: - IBOutlet
    @IBOutlet private weak var singleView: UIView!
    @IBOutlet private weak var multiView: UIView!
    @IBOutlet private weak var rightContentView: UIView!
    @IBOutlet private weak var saveView: UIView!
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet private weak var searchView: UIView!
    @IBOutlet private weak var searchButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var singleLabel: UILabel!
    @IBOutlet private weak var detailView: UIView!
    @IBOutlet private weak var detailTitle: UILabel!
    @IBOutlet private weak var backView: UIView!

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
    @IBAction func didToFavorite() {
        delegate?.actionFavorite()
    }
    
    @IBAction func didToSearch() {
        delegate?.actionSearch()
    }
    
    @IBAction func didToClose() {
        delegate?.actionClose()
    }
    
    @objc
    private func didToBack() {
        delegate?.actionBack()
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
        case .multi(let title, let titleColor, let buttons):
            setupMultiView(title: title, titleColor: titleColor, buttons: buttons)
            singleView.isHidden = true
            multiView.isHidden = false
            detailView.isHidden = true
        case .detail(let title):
            setupDetailView(title: title)
            singleView.isHidden = true
            multiView.isHidden = true
            detailView.isHidden = false
        }
    }
    
    private func setupSingleView(title: String) {
        singleLabel.text = title
        singleLabel.textColor = .white
//        singleLabel.font = .harmonyFont(ofSize: 16, weight: .bold)
    }
    
    private func setupMultiView(title: String, titleColor: UIColor?, buttons: [RightContentType]) {
        titleLabel.text = title
        titleLabel.textColor = titleColor
//        titleLabel.font = .harmonyFont(ofSize: 32, weight: .bold)
        
        searchView.corner(8)
        searchView.backgroundColor = UIColor(hexString: "#252934")
        saveView.corner(8)
        saveView.backgroundColor = UIColor(hexString: "#252934")
        
        if buttons.isEmpty {
            searchView.isHidden = true
            saveView.isHidden = true
        } else {
            searchView.isHidden = !buttons.contains(where: { $0 == .search })
            saveView.isHidden = !buttons.contains(where: { $0 == .save })
        }
    }
    
    private func setupDetailView(title: String) {
        detailTitle.text = title
        detailTitle.textColor = UIColor(hexString: "#252934")
        detailTitle.font = .outfitFont(ofSize: 20, weight: .semiBold)
        backView.corner(4)
        backView.backgroundColor = UIColor(hexString: "#E7D9FB")
        let tapToBackView = UITapGestureRecognizer(target: self, action: #selector(didToBack))
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(tapToBackView)
    }
}

enum HeaderViewType {
    case single(title: String)
    case multi(title: String, titleColor: UIColor? = UIColor(hexString: "#060606"), rightContents: [RightContentType] = [])
    case detail(title: String)
}

enum RightContentType {
    case search
    case save
    case delete
    case share
}
