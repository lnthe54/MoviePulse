import UIKit
import RxSwift
import RxCocoa

class HomeViewController: BaseViewController {

    // MARK: - Properties
    private var navigator: HomeNavigator
    private var viewModel: HomeViewModel
    
    private let getDataTrigger = PublishSubject<Void>()
    
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
            }
            .disposed(by: disposeBag)
    }
    
    override func setupViews() {
        view.backgroundColor = UIColor(hexString: "#FAF7FE")
    }
}
