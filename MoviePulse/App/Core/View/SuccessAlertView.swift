import UIKit

class SuccessAlertView: UIView {
    
    init(title: String, message: String) {
        super.init(frame: .zero)
        backgroundColor = .white
        layer.cornerRadius = 8
        clipsToBounds = true
        
        // Icon image
        let imageView = UIImageView(image: UIImage(named: "ic_fav_active"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        
        // Circle background for icon
        let favoriteView = UIView()
        favoriteView.translatesAutoresizingMaskIntoConstraints = false
        favoriteView.backgroundColor = UIColor(hexString: "#F3EDFD")
        favoriteView.layer.cornerRadius = 20
        favoriteView.clipsToBounds = true
        favoriteView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: favoriteView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: favoriteView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 24),
            imageView.heightAnchor.constraint(equalToConstant: 24),
        ])
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.textColor = .blackColor
        titleLabel.font = .outfitFont(ofSize: 14, weight: .light)
        titleLabel.textAlignment = .center
        
        // Message label
        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = message
        messageLabel.textColor = .blackColor
        messageLabel.font = .outfitFont(ofSize: 14, weight: .semiBold)
        messageLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        addSubview(favoriteView)
        addSubview(titleLabel)
        addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            favoriteView.widthAnchor.constraint(equalToConstant: 40),
            favoriteView.heightAnchor.constraint(equalToConstant: 40),
            favoriteView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            favoriteView.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: favoriteView.bottomAnchor, constant: 12),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
