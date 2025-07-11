import UIKit
import Kingfisher

class ItemHorizontalCell: UICollectionViewCell {
    // MARK: - Properties
    private var categories: [TagType] = []
    
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
        
        collectionView.configure(withCells: [TagCell.self, RateCell.self], dataSource: self)
        collectionView.setCollectionViewLayout(UICollectionViewCompositionalLayout(section: AppLayout.tagHorizontalSection()), animated: true)
    }
    
    func bindData(_ infoObject: InfoObject) {
        posterImageView.kf.setImage(
            with: URL(string: Utils.getPosterPath(infoObject.path ?? "", size: .w342)),
            placeholder: UIImage(named: "ic_loading"),
            options: [.transition(ImageTransition.fade(1))]
        )
        nameLabel.text = infoObject.name
        categories = infoObject.categories.map { .tag(content: $0) }
        categories.insert(.rate(rate: Int(infoObject.vote ?? 0.0)), at: 0)
        collectionView.reloadData()
    }
}

extension ItemHorizontalCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tag = categories[indexPath.row]
        switch tag {
        case .rate(let rate):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RateCell.className, for: indexPath) as! RateCell
            cell.bindData(rate: rate)
            return cell
            
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCell.className, for: indexPath) as! TagCell
            cell.bindData(tag: categories[indexPath.row])
            cell.corner(cell.frame.height / 2)
            return cell
        }
    }
}
