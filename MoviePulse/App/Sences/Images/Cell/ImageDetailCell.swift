import UIKit
import Kingfisher

class ImageDetailCell: UICollectionViewCell {

    static func nib() -> UINib {
        return UINib(nibName: Self.className, bundle: nil)
    }
    
    // MARK: - IBOutlet
    @IBOutlet private weak var posterImageView: UIImageView!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    func bindData(_ imageObject: BackdropObject) {
        posterImageView.kf.setImage(
            with: URL(string: Utils.getPosterPath(imageObject.filePath, size: .w780)),
            placeholder: UIImage(named: "ic_loading"),
            options: [.transition(ImageTransition.fade(1))]
        )
    }
}
