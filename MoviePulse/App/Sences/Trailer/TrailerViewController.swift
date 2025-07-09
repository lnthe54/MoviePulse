import UIKit
import RxSwift
import RxCocoa

enum TrailerSectionType {
    case list
}

class TrailerViewController: BaseViewController {

    init(
        navigator: TrailerNavigator,
        trailers: [VideoInfo]
    ) {
        self.navigator = navigator
        self.trailers = trailers
        super.init(nibName: Self.className, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - IBOutlets
    @IBOutlet private weak var topConstraint: NSLayoutConstraint!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    private var navigator: TrailerNavigator
    private var trailers: [VideoInfo]
    
    private let gotoYoutubeTrigger = PublishSubject<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.post(name: .hideTabBar, object: nil)
    }
    
    override func setupViews() {
        topConstraint.constant = Constants.HEIGHT_NAV
        setupHeader(withType: .detail(title: "Trailers"))
        
        collectionView.register(TrailerCell.nib(), forCellWithReuseIdentifier: TrailerCell.className)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        configureCompositionalLayout()
    }
    
    override func actionBack() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Private functions
    private func configureCompositionalLayout() {
       let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, _) in
            guard let self = self else { return AppLayout.defaultSection() }
            let section = self.getSections()[sectionIndex]
            
            switch section {
            case .list:
                return AppLayout.trailerListSection()
            }
        }
        
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    private func getSections() -> [ListItemSectionType] {
        var sections: [ListItemSectionType] = []
        
        if trailers.isNotEmpty {
            sections.append(.list)
        }
        
        return sections
    }
}

extension TrailerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return getSections().count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionType = getSections()[section]
        switch sectionType {
        case .list:
            return trailers.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionType = getSections()[indexPath.section]
        switch sectionType {
        case .list:
            return trailerCell(collectionView, cellForItemAt: indexPath)
        }
    }
    
    private func trailerCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> TrailerCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrailerCell.className, for: indexPath) as! TrailerCell
        cell.bindData(trailers[indexPath.row])
        return cell
    }
}

extension TrailerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch getSections()[indexPath.section] {
        case .list:
            Utils.openYoutube(with: trailers[indexPath.row].key)
        default: break
        }
    }
}
