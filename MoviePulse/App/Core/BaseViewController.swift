import UIKit
import RxSwift

class BaseViewController: UIViewController {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        bindViewModel()
        setupViews()
    }
    
    func bindViewModel() {}
    
    func setupViews() {}
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension BaseViewController {
    func titleHeaderSection(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        indexPath: IndexPath,
        title: String,
        isShowSeeMore: Bool
    ) -> TitleHeaderSection {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TitleHeaderSection.className,
            for: indexPath
        ) as! TitleHeaderSection
        header.bindData(title, isShowSeeMore: isShowSeeMore)
        return header
    }
}
