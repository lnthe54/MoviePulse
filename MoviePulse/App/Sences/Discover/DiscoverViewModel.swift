import RxSwift
import RxCocoa

class DiscoverViewModel: ViewModelType {
    
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
            .flatMapLatest(weak: self) { (self, type) in
                switch type {
                case .movie:
                    return self.getAllMovieDataTrigger(loading: loading, error: error)
                case .tv:
                    return self.getAllShowDataTrigger(loading: loading, error: error)
                case .actor:
                    return Observable.just(DiscoverData(populars: [], categories: []))
                }
            }
        
        let gotoDetailItemEvent = input.gotoDetailItemTrigger
            .flatMapLatest(weak: self) { (self, infoObject) in
                self.getDetailItem(
                    loading: loading,
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

extension DiscoverViewModel {
    private func getAllMovieDataTrigger(loading: ActivityIndicator, error: ErrorTracker) -> Observable<DiscoverData> {
        let getPopularsTrigger = movieServices
            .getMoviePopular(at: 1, categoryId: 0)
            .trackError(error)
            .trackActivity(loading)
        
        let getTopRatesTrigger = movieServices
            .getMovieTopRate(at: 1)
            .trackError(error)
            .trackActivity(loading)
        
        return Observable.zip(getPopularsTrigger, getTopRatesTrigger)
            .map { (popular, topRate) in
                let populars = Utils.transformToInfoObject(movies: popular.results)
                let topRates = Utils.transformToInfoObject(movies: topRate.results)
                let categories = CodableManager.shared.getMovieCategories()
                return DiscoverData(populars: populars, topRates: topRates, categories: categories)
            }
    }
    
    private func getAllShowDataTrigger(loading: ActivityIndicator, error: ErrorTracker) -> Observable<DiscoverData> {
        let getTrendingsTrigger = tvShowServices
            .getTrending(page: 1)
            .trackError(error)
            .trackActivity(loading)
        
        let getOnAirTodayTrigger = tvShowServices
            .getTVShowsLastest(page: 1)
            .trackError(error)
            .trackActivity(loading)
        
        let getTopratesTrigger = tvShowServices
            .getTVShowsPopular(page: 1)
            .trackError(error)
            .trackActivity(loading)
        
        let getCategoriesTrigger = tvShowServices
            .getTVShowCategories()
            .trackError(error)
            .trackActivity(loading)
            .doOnNext { categoryInfo in
                CodableManager.shared.saveTVCategories(categoryInfo.genres)
            }
        
        return Observable.zip(getTrendingsTrigger, getOnAirTodayTrigger, getTopratesTrigger, getCategoriesTrigger)
            .map { (trending, onAir, toprate, category) in
                let trendings = Utils.transformToInfoObject(tvShows: trending.results)
                let onAirs = Utils.transformToInfoObject(tvShows: onAir.results)
                let topRates = Utils.transformToInfoObject(tvShows: toprate.results)
                let categories = category.genres
                return DiscoverData(trendings: trendings, onAirs: onAirs, topRates: topRates, categories: categories)
            }
    }
    
    private func getDetailItem(
        loading: ActivityIndicator,
        error: ErrorTracker,
        infoObject: InfoObject
    ) -> Observable<InfoDetailObject> {
        switch infoObject.type {
        case .movie:
            return self.movieServices
                .getMovieDetail(infoObject.id)
                .trackError(error)
                .trackActivity(loading)
                .map { $0.transformToInfoDetailObject() }
        case .tv:
            return self.tvShowServices
                .getTVShowDetail(id: infoObject.id)
                .trackError(error)
                .trackActivity(loading)
                .map { $0.transformToInfoDetailObject()}
        default:
            return Observable.just(InfoDetailObject.empty())
        }
    }
}

extension DiscoverViewModel {
    struct Input {
        let getDataTrigger: Observable<ObjectType>
        let gotoDetailItemTrigger: Observable<InfoObject>
    }
    
    struct Output {
        let loadingEvent: Driver<Bool>
        let errorEvent: Driver<Error>
        let getDataEvent: Driver<DiscoverData>
        let gotoDetailItemEvent: Driver<InfoDetailObject>
    }
}

struct DiscoverData {
    let populars: [InfoObject]
    
    let trendings: [InfoObject]
    
    let onAirs: [InfoObject]
    
    let topRates: [InfoObject]

    let categories: [CategoryObject]
    
    init(
        populars: [InfoObject] = [],
        trendings: [InfoObject] = [],
        onAirs: [InfoObject] = [],
        topRates: [InfoObject] = [],
        categories: [CategoryObject] = []
    ) {
        self.populars = populars
        self.trendings = trendings
        self.onAirs = onAirs
        self.topRates = topRates
        self.categories = categories
    }
}
