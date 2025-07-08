import RxSwift
import RxCocoa

class FavoriteViewModel: ViewModelType {
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
        
        let getDataEvent = input.getDataTrigger
            .flatMapLatest { type in
                let favorites = CodableManager.shared.getListFavorite().filter { $0.type == type }
                return Observable.just(favorites)
            }
        
        let gotoDetailItemEvent = input.gotoDetailItemTrigger
            .flatMapLatest(weak: self) { (self, infoObject) in
                self.getDetailItem(
                    withloading: loading,
                    error: error,
                    infoObject: infoObject
                )
            }
        
        return Output(
            loadingEvent: loading.asDriver(),
            errorEvent: error.asDriver(),
            getDataEvent: getDataEvent.asDriverOnErrorJustComplete(),
            gotoDetailItemEvent: gotoDetailItemEvent.asDriverOnErrorJustComplete()
        )
    }
}

extension FavoriteViewModel {
    private func getDetailItem(
        withloading loading: ActivityIndicator,
        error: ErrorTracker,
        infoObject: InfoObject
    ) -> Observable<InfoDetailObject> {
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
            return Observable.just(InfoDetailObject.empty())
        }
    }
}

extension FavoriteViewModel {
    struct Input {
        let getDataTrigger: Observable<ObjectType>
        let gotoDetailItemTrigger: Observable<InfoObject>
    }
    
    struct Output {
        let loadingEvent: Driver<Bool>
        let errorEvent: Driver<Error>
        let getDataEvent: Driver<[InfoDetailObject]>
        let gotoDetailItemEvent: Driver<InfoDetailObject>
    }
}

