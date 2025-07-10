import RxSwift
import RxCocoa

class SeasonViewModel: ViewModelType {
    
    // MARK: - Properties
    private var tvShowServices: TVShowServices
    
    init(tvShowServices: TVShowServices = TVShowClient()) {
        self.tvShowServices = tvShowServices
    }
    
    func transform(input: Input) -> Output {
        let loading = ActivityIndicator()
        let error = ErrorTracker()
        
        let gotoDetailSeasonEvent = input.gotoDetailSeasonTrigger
            .flatMapLatest(weak: self) { (self, params) in
                return self.tvShowServices
                    .getSeasons(idTVShow: params.idTVShow, index: params.index)
                    .trackError(error)
                    .trackActivity(loading)
            }
        
        return Output(
            loadingEvent: loading.asDriver(),
            errorEvent: error.asDriver(),
            gotoDetailSeasonEvent: gotoDetailSeasonEvent.asDriverOnErrorJustComplete()
        )
    }
}

extension SeasonViewModel {
    struct Input {
        let gotoDetailSeasonTrigger: Observable<RequestSeasonDetail>
    }
    
    struct Output {
        let loadingEvent: Driver<Bool>
        let errorEvent: Driver<Error>
        let gotoDetailSeasonEvent: Driver<SeasonInfo>
    }
}

