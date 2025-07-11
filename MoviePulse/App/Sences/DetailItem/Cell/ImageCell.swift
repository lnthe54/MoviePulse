import UIKit
import Kingfisher

class ImageCell: UICollectionViewCell {
    // MARK: - IBOutlet
    @IBOutlet private weak var posterImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.corner(8)
    }
    
    func bindData(path: String?) {
        posterImageView.kf.setImage(
            with: URL(string: Utils.getPosterPath(path ?? "", size: .w342)),
            placeholder: UIImage(named: "ic_loading"),
            options: [.transition(ImageTransition.fade(1))]
        )
    }
}
