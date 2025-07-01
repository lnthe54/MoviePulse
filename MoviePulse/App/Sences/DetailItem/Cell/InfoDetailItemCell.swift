import UIKit

class InfoDetailItemCell: UICollectionViewCell {

    static func nib() -> UINib {
        return UINib(nibName: Self.className, bundle: nil)
    }
    
    // MARK: - IBOutlets
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    private var categories: [TagType] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }
    
    private func setupViews() {
        containerView.backgroundColor = .white
        containerView.corner(8)
        
        nameLabel.textColor = .blackColor
        nameLabel.font = .outfitFont(ofSize: 20, weight: .semiBold)
        nameLabel.numberOfLines = 0
        nameLabel.textAlignment = .center
        
        collectionView.register(RateCell.nib(), forCellWithReuseIdentifier: RateCell.className)
        collectionView.register(TagCell.nib(), forCellWithReuseIdentifier: TagCell.className)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.setCollectionViewLayout(UICollectionViewCompositionalLayout(section: AppLayout.tagHorizontalSection()), animated: true)
    }
    
    func bindData(_ data: InfoDetailObject) {
        nameLabel.text = data.name
        
        categories.append(.release(date: data.releaseDate))
        categories.append(.rate(rate: Int(data.vote ?? 0.0)))
        categories.append(.time(time: data.runtime ?? 0))
        categories.append(contentsOf: data.genres.map { .tag(content: $0.name) })
        collectionView.reloadData()
    }
}

extension InfoDetailItemCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch categories[indexPath.row] {
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
