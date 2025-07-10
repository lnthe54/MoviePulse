import UIKit

class SettingCell: UICollectionViewCell {

    static func nib() -> UINib {
        return UINib(nibName: Self.className, bundle: nil)
    }
    
    // MARK: - IBOutlets
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var notificationButton: UISwitch!
    @IBOutlet private weak var arrowImageView: UIImageView!
    
    var showNotificationPopup: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }

    private func setupViews() {
        containerView.corner(4)
        containerView.backgroundColor = .white
        
        titleLabel.textColor = .blackColor
        titleLabel.font = .outfitFont(ofSize: 14, weight: .medium)
        
        notificationButton.onTintColor = .pimaryColor
        notificationButton.tintColor = .lightGray
    }
    
    func bindData(type: SettingType) {
        titleLabel.text = type.title
        iconImageView.image = UIImage(named: type.icon)
        arrowImageView.isHidden = type == .notification
        notificationButton.isHidden = type != .notification
        notificationButton.isOn = NotificationManager.shared.isNotificationEnabled()
    }
    
    @IBAction func notificationToggled(_ sender: UISwitch) {
        if sender.isOn {
            NotificationManager.shared.checkSystemNotificationPermission { granted in
                DispatchQueue.main.async {
                    if granted {
                        NotificationManager.shared.setNotificationEnabled(true)
                    } else {
                        self.showNotificationPopup?()
                        sender.isOn = false
                    }
                }
            }
        } else {
            NotificationManager.shared.setNotificationEnabled(false)
        }
    }
}
