import RxSwift
import RxCocoa

class SavePulseViewModel: ViewModelType {
    struct Input {
        let getDataTrigger: Observable<Void>
    }
    
    struct Output {
        let loadingEvent: Driver<Bool>
        let errorEvent: Driver<Error>
        let getDataEvent: Driver<[PulseResultInfo]>
    }
    
    func transform(input: Input) -> Output {
        let loading = ActivityIndicator()
        let error = ErrorTracker()
        
        let getDataEvent = input.getDataTrigger
            .flatMapLatest(weak: self) { (self, _) in
                let results = CodableManager.shared.getPulseResults().sorted { $0.date > $1.date }
                return Observable.just(results)
            }
        
        return Output(
            loadingEvent: loading.asDriver(),
            errorEvent: error.asDriver(),
            getDataEvent: getDataEvent.asDriverOnErrorJustComplete()
        )
    }
}

