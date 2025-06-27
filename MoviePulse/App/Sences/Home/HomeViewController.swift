import UIKit
import RxSwift
import RxCocoa

enum HomeSectionType {
    case populars
}

class HomeViewController: BaseViewController {

    // MARK: - Properties
    private var navigator: HomeNavigator
    private var viewModel: HomeViewModel
    private var homeDataObject: HomeDataObject = HomeDataObject(movies: [], categories: [])
    
    private let getDataTrigger = PublishSubject<Void>()
    
    // MARK: - IBOutlets
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private enum Constant {
        static let maxDisplayItems: Int = 10
    }
    
    init(navigator: HomeNavigator, viewModel: HomeViewModel) {
        self.navigator = navigator
        self.viewModel = viewModel
        super.init(nibName: Self.className, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getDataTrigger.onNext(())
    }
    
    override func bindViewModel() {
        let input = HomeViewModel.Input(
            getDataTrigger: getDataTrigger.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        output.getDataEvent
            .driveNext { [weak self] homeDataObject in
                guard let self else { return }
                
                self.homeDataObject = homeDataObject
                collectionView.reloadData()
            }
            .disposed(by: disposeBag)
    }
    
    override func setupViews() {
        view.backgroundColor = UIColor(hexString: "#FAF7FE")
        
        collectionView.register(ItemHorizontalCell.nib(), forCellWithReuseIdentifier: ItemHorizontalCell.className)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        configureCompositionalLayout()
    }
}

extension HomeViewController {
    private func configureCompositionalLayout() {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, _) in
            guard let self = self else { return AppLayout.defaultSection() }
            let section = self.getSections()[sectionIndex]
            
            switch section {
            case .populars:
                return AppLayout.horizontalSection()
            }
        }
        
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    private func getSections() -> [HomeSectionType] {
        var sections: [HomeSectionType] = []
        
        if homeDataObject.movies.isNotEmpty {
            sections.append(.populars)
        }
        
        return sections
    }
    
    // MARK: - Bind Cell
    private func itemHorizontalCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> ItemHorizontalCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemHorizontalCell.className, for: indexPath) as! ItemHorizontalCell
        cell.bindData(homeDataObject.movies[indexPath.row])
        return cell
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return getSections().count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch getSections()[section] {
        case .populars:
            return homeDataObject.movies.count > Constant.maxDisplayItems ? Constant.maxDisplayItems : homeDataObject.movies.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch getSections()[indexPath.section] {
        case .populars:
            return itemHorizontalCell(collectionView, cellForItemAt: indexPath)
        }
    }
}

extension HomeViewController: UICollectionViewDelegate {
    
}
