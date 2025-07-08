import RxSwift
import RxCocoa

class SearchViewModel: ViewModelType {
    
    func transform(input: Input) -> Output {
        let loading = ActivityIndicator()
        let error = ErrorTracker()
        
        let getListKeyEvent = input.getListKeySearchTrigger
            .flatMapLatest {
                let keys = CodableManager.shared.getListKeySearch()
                return Observable.just(keys)
            }
        
        return Output(
            loadingEvent: loading.asDriver(),
            errorEvent: error.asDriver(),
            getListKeyEvent: getListKeyEvent.asDriverOnErrorJustComplete()
        )
    }
}

extension SearchViewModel {
    struct Input {
        let getListKeySearchTrigger: Observable<Void>
    }
    
    struct Output {
        let loadingEvent: Driver<Bool>
        let errorEvent: Driver<Error>
        let getListKeyEvent: Driver<[String]>
    }
}

