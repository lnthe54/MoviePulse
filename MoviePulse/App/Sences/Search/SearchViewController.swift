import UIKit
import RxSwift
import RxCocoa
import RxGesture

enum SearchSectionType {
    case recent
}

class SearchViewController: BaseViewController {

    // MARK: - Properties
    private var navigator: SearchNavigator
    private var viewModel: SearchViewModel
    private var keys: [String] = []
    
    private let getListKeySearchTrigger = PublishSubject<Void>()
    
    init(navigator: SearchNavigator, viewModel: SearchViewModel) {
        self.navigator = navigator
        self.viewModel = viewModel
        super.init(nibName: Self.className, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - IBOutlets
    @IBOutlet private weak var backView: UIView!
    @IBOutlet private weak var searchView: UIView!
    @IBOutlet private weak var searchTf: UITextField!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getListKeySearchTrigger.onNext(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.post(name: .hideTabBar, object: true)
    }
    
    override func setupViews() {
        backView.backgroundColor = UIColor(hexString: "#E7D9FB")
        backView.corner(4)
        backView.rx.tapGesture().when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.navigator.popToViewController()
            })
            .disposed(by: disposeBag)
        
        searchView.backgroundColor = .white
        searchView.corner(8)
        
        searchTf.attributedPlaceholder = NSAttributedString(
            string: "Search any movies or shows",
            attributes: [
                .foregroundColor: UIColor(hexString: "#697081") ?? .clear
            ]
        )
        
        searchTf.textColor = .blackColor
        searchTf.tintColor = .pimaryColor
        searchTf.delegate = self
        searchTf.returnKeyType = .search
        searchTf.becomeFirstResponder()
        
        collectionView.register(RecentCell.nib(), forCellWithReuseIdentifier: RecentCell.className)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        configureCompositionalLayout()
    }
    
    override func bindViewModel() {
        let input = SearchViewModel.Input(
            getListKeySearchTrigger: getListKeySearchTrigger
        )
        let output = viewModel.transform(input: input)
        
        output.loadingEvent
            .driveNext { isLoading in
                if isLoading {
                    LoadingView.shared.startLoading()
                } else {
                    LoadingView.shared.endLoading()
                }
            }
            .disposed(by: disposeBag)
        
        output.errorEvent
            .driveNext { _ in
                // Do something
            }
            .disposed(by: disposeBag)
        
        output.getListKeyEvent
            .driveNext { [weak self] keys in
                guard let self else { return }
                
                self.keys = keys
                collectionView.reloadData()
            }
            .disposed(by: disposeBag)
    }
}

extension SearchViewController {
    private func configureCompositionalLayout() {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, _) in
            guard let self = self else { return AppLayout.defaultSection() }
            let section = self.getSections()[sectionIndex]
            
            switch section {
            case .recent:
                return AppLayout.recentSection()
            }
        }
        
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    private func getSections() -> [SearchSectionType] {
        var sections: [SearchSectionType] = []
        
        if keys.isNotEmpty {
            sections.append(.recent)
        }
        
        return sections
    }
    
    private func handleRemoveKey(_ key: String) {
        var keys = CodableManager.shared.getListKeySearch()
        keys.removeAll(where: { $0 == key})
        CodableManager.shared.saveKeys(keys)
        getListKeySearchTrigger.onNext(())
    }
}

extension SearchViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return getSections().count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch getSections()[section] {
        case .recent:
            return keys.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch getSections()[indexPath.section] {
        case .recent:
            return recentCell(collectionView, cellForItemAt: indexPath)
        }
    }
    
    private func recentCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> RecentCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentCell.className, for: indexPath) as! RecentCell
        cell.didToRemove = { [weak self] key in
            self?.handleRemoveKey(key)
        }
        cell.bindData(with: keys[indexPath.row])
        return cell
    }
}

extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch getSections()[indexPath.section] {
        case .recent:
            break
        }
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let keySearch = textField.text else {
            textField.resignFirstResponder()
            return true
        }
        
        guard !keySearch.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            textField.resignFirstResponder()
            return true
        }
        
        CodableManager.shared.saveKeySearch(keySearch)
        
        textField.resignFirstResponder()
        return true
    }
}
