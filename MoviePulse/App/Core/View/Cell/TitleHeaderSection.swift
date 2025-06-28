import UIKit
import RxGesture
import RxSwift
import RxCocoa

protocol TitleHeaderSectionDelegate: NSObjectProtocol {
    func didToSeeMore(sectionType: Any)
}

class TitleHeaderSection: UICollectionReusableView {

    static func nib() -> UINib {
        return UINib(nibName: TitleHeaderSection.className, bundle: nil)
    }
    
    // MARK: - IBOutlets
    @IBOutlet private weak var titleSection: UILabel!
    @IBOutlet private weak var seeMoreButton: UILabel!
    
    weak var delegate: TitleHeaderSectionDelegate?
    
    private let disposeBag = DisposeBag()
    private var sectionType: Any!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        titleSection.textColor = .blackColor
        titleSection.font = .outfitFont(ofSize: 16, weight: .semiBold)
        
        seeMoreButton.rx.tapGesture().when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.delegate?.didToSeeMore(sectionType: sectionType!)
            })
            .disposed(by: disposeBag)
        
        seeMoreButton.textColor = .pimaryColor
        seeMoreButton.text = "See more"
        seeMoreButton.font = .outfitFont(ofSize: 14)
    }
    
    func bindData(_ title: String, isShowSeeMore: Bool = false, sectionType: Any) {
        titleSection.text = title
        seeMoreButton.isHidden = !isShowSeeMore
        self.sectionType = sectionType
    }
}
