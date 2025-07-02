import UIKit
import RxSwift

class BaseViewController: UIViewController {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var headerView: BaseHeaderView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        view.backgroundColor = UIColor(hexString: "#FAF7FE")
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
    
    @objc func actionSearch() {
        // Do something
    }
    
    @objc func actionBack() {
        // Do something
    }
    
    @objc func actionShare() {
        showPopupShareApp()
    }
    
    @objc func didToFinish(name: String) {
        
    }
    
    @objc func actionClose() {
        
    }
    
    @objc func actionDelete() {
        
    }
}

extension BaseViewController {
    func showPopupShareApp() {
        if let urlStr = NSURL(string: Constants.Config.URL_SHARE_APP) {
            let objectsToShare = [urlStr]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                if let popup = activityVC.popoverPresentationController {
                    popup.sourceView = self.view
                    popup.sourceRect = CGRect(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 4, width: 0, height: 0)
                }
            }
            
            self.present(activityVC, animated: true, completion: nil)
        }
    }
}
