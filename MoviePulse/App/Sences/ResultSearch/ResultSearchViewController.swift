import UIKit
import RxSwift
import RxCocoa
import RxGesture

enum ResultSearchSectionType {
    case list
    case empty
}

class ResultSearchViewController: BaseViewController {

    // MARK: - Properties
    private var navigator: ResultSearchNavigator
    private var viewModel: ResultSearchViewModel
    private var key: String
    private var items: [InfoObject] = []
    private var type: ObjectType = .movie
    
    private let getDataTrigger = PublishSubject<String>()
    private let gotoDetailItemTrigger = PublishSubject<InfoObject>()
    
    // MARK: - IBOutlets
    @IBOutlet private weak var backView: UIView!
    @IBOutlet private weak var searchView: UIView!
    @IBOutlet private weak var searchTf: UITextField!
    @IBOutlet private weak var movieView: UIView!
    @IBOutlet private weak var movieIndicatorView: UIView!
    @IBOutlet private weak var movieLabel: UILabel!
    @IBOutlet private weak var tvShowView: UIView!
    @IBOutlet private weak var tvIndicatorView: UIView!
    @IBOutlet private weak var tvShowLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    init(
        navigator: ResultSearchNavigator,
        viewModel: ResultSearchViewModel,
        key: String
    ) {
        self.navigator = navigator
        self.viewModel = viewModel
        self.key = key
        super.init(nibName: Self.className, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getDataTrigger.onNext(key)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.post(name: .hideTabBar, object: true)
    }
    
    override func bindViewModel() {
        let input = ResultSearchViewModel.Input(
            getDataTrigger: getDataTrigger.asObservable(),
            gotoDetailItemTrigger: gotoDetailItemTrigger.asObservable()
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
        
        output.getDataEvent
            .driveNext { [weak self] items in
                guard let self else { return }
                
                self.items = items
                self.collectionView.reloadData()
            }
            .disposed(by: disposeBag)
        
        output.gotoDetailItemEvent
            .driveNext { [weak self] infoDetailObject in
                self?.navigator.gotoDetailItemViewController(infoDetailObject: infoDetailObject)
            }
            .disposed(by: disposeBag)
    }
    
    override func setupViews() {
        backView.backgroundColor = UIColor(hexString: "#E7D9FB")
        backView.corner(4)
        backView.rx.tapGesture().when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.navigator.popToRootView()
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
        
        searchTf.text = key
        searchTf.textColor = .blackColor
        searchTf.tintColor = .pimaryColor
        searchTf.returnKeyType = .search
        searchTf.delegate = self
        
        movieView.rx.tapGesture().when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.didToMoviesTab()
            })
            .disposed(by: disposeBag)
        movieLabel.text = "Movies"
        movieIndicatorView.backgroundColor = .pimaryColor
        movieIndicatorView.corner(2)
        
        tvShowView.rx.tapGesture().when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.didToTVShowsTab()
        })
        .disposed(by: disposeBag)
        tvShowLabel.text = "TV Shows"
        tvIndicatorView.backgroundColor = .pimaryColor
        tvIndicatorView.corner(2)
        
        // Default
        didToMoviesTab()
        
        collectionView.configure(
            withCells: [ItemHorizontalCell.self, EmptyCell.self],
            delegate: self,
            dataSource: self
        )
        configureCompositionalLayout()
    }
}

extension ResultSearchViewController {
    private func didToMoviesTab() {
        type = .movie
        movieLabel.textColor = .pimaryColor
        movieLabel.font = .outfitFont(ofSize: 14, weight: .semiBold)
        movieIndicatorView.isHidden = false
        
        tvShowLabel.textColor = UIColor(hexString: "#697081")
        tvShowLabel.font = .outfitFont(ofSize: 14, weight: .light)
        tvIndicatorView.isHidden = true
        collectionView.reloadData()
    }
    
    private func didToTVShowsTab() {
        type = .tv
        tvIndicatorView.isHidden = false
        tvShowLabel.textColor = .pimaryColor
        tvShowLabel.font = .outfitFont(ofSize: 14, weight: .semiBold)
        
        movieIndicatorView.isHidden = true
        movieLabel.textColor = UIColor(hexString: "#697081")
        movieLabel.font = .outfitFont(ofSize: 14, weight: .light)
        collectionView.reloadData()
    }
    
    private func configureCompositionalLayout() {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, _) in
            guard let self = self else { return AppLayout.defaultSection() }
            let section = self.getSections()[sectionIndex]
            
            switch section {
            case .list:
                return AppLayout.itemsSection()
            case .empty:
                return AppLayout.fixedSection(height: 300)
            }
        }
        
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    private func getSections() -> [ResultSearchSectionType] {
        var sections: [ResultSearchSectionType] = []
        
        let filterItems = items.filter { $0.type == type }
        
        if filterItems.isEmpty {
            sections.append(.empty)
        } else {
            sections.append(.list)
        }
        
        return sections
    }
}

extension ResultSearchViewController: UITextFieldDelegate {
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
        getDataTrigger.onNext(keySearch)
        
        textField.resignFirstResponder()
        return true
    }
}

extension ResultSearchViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return getSections().count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch getSections()[section] {
        case .list:
            return items.filter { $0.type == type }.count
        case .empty:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch getSections()[indexPath.section] {
        case .list:
            return itemCell(collectionView, cellForItemAt: indexPath)
        case .empty:
            return emptyCell(collectionView, cellForItemAt: indexPath)
        }
    }
    
    private func itemCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> ItemHorizontalCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemHorizontalCell.className, for: indexPath) as! ItemHorizontalCell
        let filterItems = items.filter { $0.type == type }
        cell.bindData(filterItems[indexPath.row])
        return cell
    }
    
    private func emptyCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> EmptyCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyCell.className, for: indexPath) as! EmptyCell
        cell.bindData(title: "Nothing here", message: "Please try with another keyword", isHideButton: true)
        return cell
    }
}

extension ResultSearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch getSections()[indexPath.section] {
        case .list:
            gotoDetailItemTrigger.onNext(items[indexPath.row])
        default: break
        }
    }
}
