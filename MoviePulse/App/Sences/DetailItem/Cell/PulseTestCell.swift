import UIKit

class PulseTestCell: UICollectionViewCell {
    // MARK: - IBOutlets
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var startButton: UIButton!
    @IBOutlet private weak var contentLabel: UILabel!
    
    var onStartTest: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }

    private func setupViews() {
        containerView.backgroundColor = UIColor(hexString: "#E7D9FB")
        containerView.corner(4)
        
        contentLabel.text = "How did this movie make your heart feel?"
        contentLabel.textColor = .blackColor
        contentLabel.numberOfLines = 0
        contentLabel.font = .outfitFont(ofSize: 14, weight: .semiBold)
        
        startButton.corner(startButton.frame.height / 2)
        startButton.backgroundColor = .pimaryColor
        startButton.setTitle("Start Pulse Test", for: .normal)
        startButton.setTitleColor(.white, for: .normal)
        startButton.titleLabel?.font = .outfitFont(ofSize: 14, weight: .semiBold)
    }
    
    @IBAction private func startTest() {
        onStartTest?()
    }
}
