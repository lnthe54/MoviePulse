import RxSwift
import RxCocoa

class HomeViewModel: ViewModelType {
    
    // MARK: - Properties
    private var movieService: MovieServices
    
    init(movieService: MovieServices) {
        self.movieService = movieService
    }
    
    func transform(input: Input) -> Output {
        let loading = ActivityIndicator()
        let error = ErrorTracker()
        
        let popularMoviesTrigger = input.getDataTrigger
            .flatMapLatest(weak: self) { (self, _) in
                self.movieService
                    .getMoviePopular(at: 1, categoryId: 0)
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
        
        let getAllDataEvent = Observable.zip(popularMoviesTrigger, categoriesTrigger)
            .doOnNext { (_, category) in
                CodableManager.shared.saveMovieCategories(category.genres)
            }
            .map {
                HomeDataObject(movies: Utils.transformToInfoObject(movies: $0.results), categories: $1.genres)
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
