import RxSwift
import RxCocoa

class HomeViewModel: ViewModelType {
    
    func transform(input: Input) -> Output {
        return Output()
    }
}

extension HomeViewModel {
    struct Input {
        let getDataTrigger: Observable<Void>
    }
    
    struct Output {
        
    }
}
