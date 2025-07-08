import UIKit

class RecentHeaderCell: UICollectionReusableView {

    static func nib() -> UINib {
        return UINib(nibName: Self.className, bundle: nil)
    }
    
    // MARK: - IBOutlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var clearButton: UIButton!
    
    var didToClear: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }
    
    private func setupViews() {
        titleLabel.text = "Recent search"
        titleLabel.textColor = .blackColor
        titleLabel.font = .outfitFont(ofSize: 16, weight: .semiBold)
        
        clearButton.setTitle("Clear all", for: .normal)
        clearButton.setTitleColor(.pimaryColor, for: .normal)
        clearButton.titleLabel?.font = .outfitFont(ofSize: 14, weight: .regular)
    }
    
    @IBAction func actionClear() {
        didToClear?()
    }
}
