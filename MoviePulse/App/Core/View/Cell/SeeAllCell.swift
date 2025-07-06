import UIKit
import RxSwift
import RxCocoa
import RxGesture

protocol SeeAllCellDelegate: NSObjectProtocol {
    func didSeeAll()
}

class SeeAllCell: UICollectionViewCell {

    static func nib() -> UINib {
        return UINib(nibName: Self.className, bundle: nil)
    }
    
    // MARK: - IBOutlets
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var seeMoreView: UIView!
    @IBOutlet private weak var seeMoreLabel: UILabel!
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    weak var delegate: SeeAllCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }

    private func setupViews() {
        containerView.backgroundColor = .pimaryColor
        containerView.corner(8)
        containerView.clipsToBounds = true

        titleLabel.textColor = .white
        titleLabel.font = .outfitFont(ofSize: 20, weight: .semiBold)
        titleLabel.numberOfLines = 0
        
        posterImageView.contentMode = .scaleAspectFill
        
        seeMoreView.rx.tapGesture().when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.delegate?.didSeeAll()
            })
            .disposed(by: disposeBag)
        
        seeMoreView.backgroundColor = .white
        seeMoreView.corner(seeMoreView.frame.height / 2)
        seeMoreLabel.textColor = .pimaryColor
        seeMoreLabel.text = "See all"
        seeMoreLabel.font = .outfitFont(ofSize: 14, weight: .semiBold)
    }
    
    func bindData(_ data: InfoObject) {
        titleLabel.text = data.name
        posterImageView.image = UIImage(named: data.path ?? "")
    }
}
