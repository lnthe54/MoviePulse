import RxSwift
import RxCocoa

class DetailItemViewModel: ViewModelType {
    
    // MARK: - Properties
    private var movieServices: MovieServices
    private var tvShowServices: TVShowServices
    
    init(
        movieServices: MovieServices = MovieClient(),
        tvShowServices: TVShowServices = TVShowClient()
    ) {
        self.movieServices = movieServices
        self.tvShowServices = tvShowServices
    }
    
    func transform(input: Input) -> Output {
        let loading = ActivityIndicator()
        let error = ErrorTracker()
        
        let gotoDetailItemEvent = input.gotoDetailItemTrigger
            .flatMapLatest(weak: self) { (self, infoObject) in
                self.getDetailItemObject(withLoading: loading, error: error, infoObject: infoObject)
            }
        
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
            gotoDetailItemEvent: gotoDetailItemEvent.asDriverOnErrorJustComplete(),
            gotoDetailSeasonEvent: gotoDetailSeasonEvent.asDriverOnErrorJustComplete()
        )
    }
}

extension DetailItemViewModel {
    private func getDetailItemObject(withLoading loading: ActivityIndicator, error: ErrorTracker, infoObject: InfoObject) -> Observable<InfoDetailObject> {
        switch infoObject.type {
        case .movie:
            return movieServices
                .getMovieDetail(infoObject.id)
                .trackError(error)
                .trackActivity(loading)
                .map { $0.transformToInfoDetailObject() }
        case .tv:
            return tvShowServices
                .getTVShowDetail(id: infoObject.id)
                .trackError(error)
                .trackActivity(loading)
                .map { $0.transformToInfoDetailObject() }
        default:
            return Observable.just(.empty())
        }
    }
}

extension DetailItemViewModel {
    struct Input {
        let gotoDetailItemTrigger: Observable<InfoObject>
        let gotoDetailSeasonTrigger: Observable<RequestSeasonDetail>
    }
    
    struct Output {
        let loadingEvent: Driver<Bool>
        let errorEvent: Driver<Error>
        let gotoDetailItemEvent: Driver<InfoDetailObject>
        let gotoDetailSeasonEvent: Driver<SeasonInfo>
    }
}

struct RequestSeasonDetail {
    let idTVShow: Int
    
    let index: Any
}
