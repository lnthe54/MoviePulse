import UIKit

class TagCell: UICollectionViewCell {
    // MARK: - IBOutlets
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }
    
    private func setupViews() {
        containerView.backgroundColor = UIColor(hexString: "#E7D9FB")
        
        nameLabel.font = .outfitFont(ofSize: 12, weight: .light)
        nameLabel.textColor = UIColor(hexString: "#8435F3")
    }

    func bindData(tag: TagType) {
        switch tag {
        case .tag(let content):
            containerView.backgroundColor = UIColor(hexString: "#E7D9FB")
            nameLabel.textColor = UIColor(hexString: "#8435F3")
            nameLabel.text = content
        case .time(let time):
            containerView.backgroundColor = UIColor(hexString: "#E7D9FB")
            nameLabel.textColor = UIColor(hexString: "#8435F3")
            nameLabel.text = time.toHourMinute()
        case .release(let date):
            containerView.backgroundColor = .blackColor
            nameLabel.textColor = .white
            nameLabel.text = date
        default:
            break
        }
    }
}

enum TagType {
    case tag(content: String)
    case rate(rate: Int)
    case release(date: String)
    case time(time: Int)
}
