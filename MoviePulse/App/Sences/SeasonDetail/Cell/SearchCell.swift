import UIKit
import RxSwift
import RxCocoa
import RxGesture

class SearchCell: UICollectionViewCell {
    // MARK: - IBOutlets
    @IBOutlet private weak var searchView: UIView!
    @IBOutlet private weak var searchTf: UITextField!
    
    private let disposeBag = DisposeBag()
    
    var onSearching: ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }

    private func setupViews() {
        searchView.backgroundColor = .white
        searchView.corner(8)
        
        searchTf.attributedPlaceholder = NSAttributedString(
            string: "Search any episodes...",
            attributes: [
                .foregroundColor: UIColor(hexString: "#697081") ?? .clear
            ]
        )
        
        searchTf.rx.text.orEmpty
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(onNext: { [weak self] text in
                self?.onSearching?(text)
            })
            .disposed(by: disposeBag)
        
        searchTf.textColor = .blackColor
        searchTf.tintColor = .pimaryColor
        searchTf.returnKeyType = .search
    }
}
