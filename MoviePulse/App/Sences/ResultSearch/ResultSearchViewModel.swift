import RxSwift
import RxCocoa

class ResultSearchViewModel: ViewModelType {
    
    private var movieServices: MovieServices
    private var tvShowServices: TVShowServices
    private let searchServices: SearchService
    
    init(
        movieServices: MovieServices = MovieClient(),
        tvShowServices: TVShowServices = TVShowClient(),
        searchServices: SearchService = SearchClient()
    ) {
        self.movieServices = movieServices
        self.tvShowServices = tvShowServices
        self.searchServices = searchServices
    }
    
    func transform(input: Input) -> Output {
        let loading = ActivityIndicator()
        let error = ErrorTracker()
        
        let getMoviesTrigger = input.getDataTrigger
            .flatMapLatest(weak: self) { (self, query) in
                return self.searchServices
                    .searchMovie(by: query, page: 1)
                    .trackError(error)
                    .trackActivity(loading)
            }
        
        let getTVShowsTrigger = input.getDataTrigger
            .flatMapLatest(weak: self) { (self, query) in
                return self.searchServices
                    .searchTV(by: query, page: 1)
                    .trackError(error)
                    .trackActivity(loading)
            }
        
        let getDataEvent = Observable.zip(getMoviesTrigger, getTVShowsTrigger)
            .flatMapLatest { (movie, tvShow) in
                var items: [InfoObject] = []
                items.append(contentsOf: Utils.transformToInfoObject(movies: movie.results))
                items.append(contentsOf: Utils.transformToInfoObject(tvShows: tvShow.results))
                return Observable.just(items)
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

extension ResultSearchViewModel {
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

extension ResultSearchViewModel {
    struct Input {
        let getDataTrigger: Observable<String>
        let gotoDetailItemTrigger: Observable<InfoObject>
    }
    
    struct Output {
        let loadingEvent: Driver<Bool>
        let errorEvent: Driver<Error>
        let getDataEvent: Driver<[InfoObject]>
        let gotoDetailItemEvent: Driver<InfoDetailObject>
    }
}

