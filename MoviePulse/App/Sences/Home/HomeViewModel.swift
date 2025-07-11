import RxSwift
import RxCocoa

class HomeViewModel: ViewModelType {
    
    // MARK: - Properties
    private var movieService: MovieServices
    private var tvShowServices: TVShowServices
    
    init(
        movieService: MovieServices = MovieClient(),
        tvShowServices: TVShowServices = TVShowClient()
    ) {
        self.movieService = movieService
        self.tvShowServices = tvShowServices
    }
    
    func transform(input: Input) -> Output {
        let loading = ActivityIndicator()
        let error = ErrorTracker()
        
        let popularMoviesTrigger = input.getDataTrigger
            .flatMapLatest(weak: self) { (self, _) in
                self.movieService
                    .getTrending(at: 1)
                    .trackError(error)
                    .trackActivity(loading)
            }
        
        let categoriesTrigger = input.getDataTrigger
            .flatMapLatest(weak: self) { (self, _) in
                self.movieService
                    .getMovieCategories()
                    .trackError(error)
                    .trackActivity(loading)
            }
        
        let tvShowCategoriesTrigger = input.getDataTrigger
            .flatMapLatest(weak: self) { (self, _) in
                self.tvShowServices
                    .getTVShowCategories()
                    .trackError(error)
                    .trackActivity(loading)
            }
        
        let getAllDataEvent = Observable.zip(popularMoviesTrigger, categoriesTrigger, tvShowCategoriesTrigger)
            .doOnNext { (_, movieCategory, tvShowCategory) in
                CodableManager.shared.saveMovieCategories(movieCategory.genres)
                CodableManager.shared.saveTVCategories(tvShowCategory.genres)
            }
            .map { (movieInfo, movieCategoryInfo, _) in
                HomeDataObject(movies: Utils.transformToInfoObject(movies: movieInfo.results), categories: movieCategoryInfo.genres)
            }
        
        let gotoDetailItemEvent = input.gotoDetailItemTrigger
            .flatMapLatest(weak: self) { (self, infoObject) in
                self.movieService
                    .getMovieDetail(infoObject.id)
                    .trackError(error)
                    .trackActivity(loading)
            }
            .map { $0.transformToInfoDetailObject() }
        
        return Output(
            loadingEvent: loading.asDriver(),
            errorEvent: error.asDriver(),
            getDataEvent: getAllDataEvent.asDriverOnErrorJustComplete(),
            gotoDetailItemEvent: gotoDetailItemEvent.asDriverOnErrorJustComplete()
        )
    }
}

extension HomeViewModel {
    struct Input {
        let getDataTrigger: Observable<Void>
        let gotoDetailItemTrigger: Observable<InfoObject>
    }
    
    struct Output {
        let loadingEvent: Driver<Bool>
        let errorEvent: Driver<Error>
        let getDataEvent: Driver<HomeDataObject>
        let gotoDetailItemEvent: Driver<InfoDetailObject>
    }
}

struct HomeDataObject {
    let movies: [InfoObject]
    
    let categories: [CategoryObject]
}
