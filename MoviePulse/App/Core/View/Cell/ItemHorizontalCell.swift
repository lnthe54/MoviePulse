import UIKit
import Kingfisher

class ItemHorizontalCell: UICollectionViewCell {

    static func nib() -> UINib {
        return UINib(nibName: Self.className, bundle: nil)
    }
    
    // MARK: - Properties
    private var categories: [String] = []
    
    // MARK: - IBOutlets
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }

    private func setupViews() {
        posterImageView.corner(8)
        posterImageView.contentMode = .scaleAspectFill
        nameLabel.font = .outfitFont(ofSize: 14, weight: .semiBold)
        nameLabel.textColor = .blackColor
        
        collectionView.register(TagCell.nib(), forCellWithReuseIdentifier: TagCell.className)
        collectionView.register(RateCell.nib(), forCellWithReuseIdentifier: RateCell.className)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.setCollectionViewLayout(UICollectionViewCompositionalLayout(section: AppLayout.tagHorizontalSection()), animated: true)
    }
    
    func bindData(_ infoObject: InfoObject) {
        posterImageView.kf.setImage(
            with: URL(string: Utils.getPosterPath(infoObject.path ?? "", size: .w342)),
            placeholder: UIImage(named: "ic_loading"),
            options: [.transition(ImageTransition.fade(1))]
        )
        nameLabel.text = infoObject.name
        categories = infoObject.categories
        categories.insert(String(Int(infoObject.vote ?? 0.0)), at: 0)
        collectionView.reloadData()
    }
}

extension ItemHorizontalCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RateCell.className, for: indexPath) as! RateCell
            cell.bindData(text: categories[indexPath.row])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCell.className, for: indexPath) as! TagCell
            cell.bindData(text: categories[indexPath.row])
            cell.corner(cell.frame.height / 2)
            return cell
        }
    }
}
