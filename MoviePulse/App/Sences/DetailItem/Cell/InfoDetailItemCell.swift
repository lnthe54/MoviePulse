import UIKit
import RxSwift
import RxCocoa
import RxGesture

class InfoDetailItemCell: UICollectionViewCell {
    // MARK: - IBOutlets
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var favoriteView: UIView!
    @IBOutlet private weak var favoriteImageView: UIImageView!
    @IBOutlet private weak var watchView: UIView!
    @IBOutlet private weak var watchLabel: UILabel!
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private var categories: [TagType] = []
    private var isFavorite: Bool = false
    
    var onTapFavorite: ((Bool) -> Void)?
    var onTapWatch: (() -> Void)?
    
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
        
        collectionView.configure(withCells: [RateCell.self, TagCell.self], dataSource: self)
        collectionView.setCollectionViewLayout(UICollectionViewCompositionalLayout(section: AppLayout.tagHorizontalSection()), animated: true)
        
        favoriteView.backgroundColor = UIColor(hexString: "#F3EDFD")
        favoriteView.corner(favoriteView.frame.height / 2)
        favoriteView.rx.tapGesture().when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.handleFavorite()
            })
            .disposed(by: disposeBag)
        
        watchView.backgroundColor = .pimaryColor
        watchView.corner(watchView.frame.height / 2)
        watchLabel.textColor = .white
        watchLabel.font = .outfitFont(ofSize: 14, weight: .semiBold)
        watchLabel.text = "Watch trailer"
        watchView.rx.tapGesture().when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.onTapWatch?()
            })
            .disposed(by: disposeBag)
    }
    
    func bindData(_ data: InfoDetailObject) {
        isFavorite = CodableManager.shared.getListFavorite().contains(where: { $0.id == data.id })
        favoriteImageView.image = UIImage(named: isFavorite ? "ic_fav_active" : "ic_fav_inactive")
        
        nameLabel.text = data.name
        
        categories.removeAll()
        categories.append(.release(date: data.releaseDate))
        categories.append(.rate(rate: Int(data.vote ?? 0.0)))
        if let time = data.runtime, time != 0 {
            categories.append(.time(time: time))
        }
        categories.append(contentsOf: data.genres.map { .tag(content: $0.name) })
        collectionView.reloadData()
    }
    
    private func handleFavorite() {
        isFavorite = !isFavorite
        favoriteImageView.image = UIImage(named: isFavorite ? "ic_fav_active" : "ic_fav_inactive")
        onTapFavorite?(isFavorite)
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
