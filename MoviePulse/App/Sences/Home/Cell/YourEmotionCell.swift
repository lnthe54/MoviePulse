import UIKit

class YourEmotionCell: UICollectionViewCell {

    // MARK: - IBOutlets
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var thisWeekLabel: UILabel!
    @IBOutlet private weak var bpmView: UIView!
    @IBOutlet private weak var bpmLabel: UILabel!
    @IBOutlet private weak var bpmValueLabel: UILabel!
    @IBOutlet private weak var tensionView: UIView!
    @IBOutlet private weak var tensionLabel: UILabel!
    @IBOutlet private weak var tensionValueLabel: UILabel!
    @IBOutlet private weak var timesView: UIView!
    @IBOutlet private weak var timesLabel: UILabel!
    @IBOutlet private weak var timesValueLabel: UILabel!
    @IBOutlet private weak var emotionView: UIView!
    @IBOutlet private weak var emotionLabel: UILabel!
    @IBOutlet private weak var emotionValueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }

    private func setupViews() {
        containerView.backgroundColor = .white
        containerView.corner(8)
        containerView.clipsToBounds = true
        
        titleLabel.text = "Your emotional summary"
        titleLabel.textColor = .blackColor
        titleLabel.font = .outfitFont(ofSize: 16, weight: .semiBold)
        
        thisWeekLabel.text = "This week"
        thisWeekLabel.textColor = UIColor(hexString: "#697081")
        thisWeekLabel.font = .outfitFont(ofSize: 14)
        
        // BPM
        bpmView.configSubView()
        bpmLabel.configSubLabel("Average heart rate")
        
        // Tension
        tensionView.configSubView()
        tensionLabel.configSubLabel("Average tension")
        
        // Times
        timesView.configSubView()
        timesLabel.configSubLabel("Times measured")
        
        // Emotion
        emotionView.configSubView()
        emotionLabel.configSubLabel("Emotion")
    }
}
