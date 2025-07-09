import UIKit
import RxSwift
import RxCocoa
import RxGesture

class ComponentPopup: BaseViewController {

    // MARK: - Properties
    private var titleHeader: String
    private var content: String
    private var leftValue: String
    private var rightValue: String
    
    init(
        titleHeader: String,
        content: String,
        leftValue: String,
        rightValue: String
    ) {
        self.titleHeader = titleHeader
        self.content = content
        self.leftValue = leftValue
        self.rightValue = rightValue
        super.init(nibName: Self.className, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - IBOutlets
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private weak var leftButton: UIButton!
    @IBOutlet private weak var rightButton: UIButton!
    
    var onTapLeftButton: (() -> Void)?
    var onTapRightButton: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func setupViews() {
        view.backgroundColor = .black.withAlphaComponent(0.3)
        containerView.backgroundColor = .white
        containerView.corner(12)
        
        titleLabel.text = titleHeader
        titleLabel.textColor = .blackColor
        titleLabel.font = .outfitFont(ofSize: 14, weight: .semiBold)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        contentLabel.text = content
        contentLabel.textColor = .blackColor
        contentLabel.font = .outfitFont(ofSize: 12, weight: .light)
        contentLabel.numberOfLines = 0
        contentLabel.textAlignment = .center
        
        leftButton.backgroundColor = UIColor(hexString: "#E7D9FB")
        leftButton.corner(leftButton.frame.height / 2)
        leftButton.setTitleColor(.pimaryColor, for: .normal)
        leftButton.setTitle(leftValue, for: .normal)
        leftButton.titleLabel?.font = .outfitFont(ofSize: 14, weight: .semiBold)
        leftButton.rx.tapGesture().when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.dismissPopup(completion: {
                    self?.onTapLeftButton?()
                })
                
            })
            .disposed(by: disposeBag)
        
        rightButton.backgroundColor = .pimaryColor
        rightButton.corner(rightButton.frame.height / 2)
        rightButton.setTitleColor(.white, for: .normal)
        rightButton.setTitle(rightValue, for: .normal)
        rightButton.titleLabel?.font = .outfitFont(ofSize: 14, weight: .semiBold)
        rightButton.rx.tapGesture().when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.dismissPopup(completion: {
                    self?.onTapRightButton?()
                })
            })
            .disposed(by: disposeBag)
    }
    
    private func dismissPopup(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.03, animations: {
            self.view.backgroundColor = .clear
        }) { _ in
            self.dismiss(animated: true, completion: completion)
        }
    }
}
