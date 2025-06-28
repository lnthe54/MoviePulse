import UIKit
import RxSwift

class BaseViewController: UIViewController {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var headerView: BaseHeaderView?
    
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

extension BaseViewController: TitleHeaderSectionDelegate {
    func titleHeaderSection(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        indexPath: IndexPath,
        title: String,
        isShowSeeMore: Bool,
        sectionType: Any
    ) -> TitleHeaderSection {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TitleHeaderSection.className,
            for: indexPath
        ) as! TitleHeaderSection
        header.delegate = self
        header.bindData(title, isShowSeeMore: isShowSeeMore, sectionType: sectionType)
        return header
    }
    
    @objc
    func didToSeeMore(sectionType: Any) {
        
    }
}

extension BaseViewController: BaseHeaderViewDelegate {
    // MARK: - Setup header
    func setupHeader(withType type: HeaderViewType) {
        if headerView == nil {
            headerView = BaseHeaderView.instanceFromNib()
        }
        
        if let headerView = headerView {
            _ = headerView.then {
                $0.delegate = self
                $0.moveTo(parentViewController: self)
                $0.setupHeader(withType: type)
            }
            
            view.addSubview(headerView)
            view.bringSubviewToFront(headerView)
        }
    }
    
    @objc func actionFavorite() {
        // Do something
    }
    
    @objc func actionSearch() {
        // Do something
    }
    
    @objc func actionBack() {
        // Do something
    }
    
    @objc func actionShare() {
        
    }
    
    @objc func didToFinish(name: String) {
        
    }
    
    @objc func actionClose() {
        
    }
}

