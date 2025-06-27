import UIKit

class TitleHeaderSection: UICollectionReusableView {

    static func nib() -> UINib {
        return UINib(nibName: TitleHeaderSection.className, bundle: nil)
    }
    
    // MARK: - IBOutlets
    @IBOutlet private weak var titleSection: UILabel!
    @IBOutlet private weak var seeMoreButton: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        titleSection.textColor = .blackColor
        titleSection.font = .outfitFont(ofSize: 16, weight: .semiBold)
        
        seeMoreButton.textColor = .pimaryColor
        seeMoreButton.text = "See more"
        seeMoreButton.font = .outfitFont(ofSize: 14)
    }
    
    func bindData(_ title: String, isShowSeeMore: Bool = false) {
        titleSection.text = title
        seeMoreButton.isHidden = !isShowSeeMore
    }
}
