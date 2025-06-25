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
            .flatMap(weak: self) { (self, _) in
                self.movieService
                    .getMoviePopular(at: 1, categoryId: 0)
                    .trackError(error)
                    .trackActivity(loading)
            }
        
        let categoriesTrigger = input.getDataTrigger
            .flatMap(weak: self) { (self, _) in
                self.movieService
                    .getMovieCategories()
                    .trackError(error)
                    .trackActivity(loading)
            }
        
        let getAllDataEvent = Observable.zip(popularMoviesTrigger, categoriesTrigger)
            .map { (popularInfo, categoryInfo) in
                return HomeDataObject(
                    movies: Utils.transformToInfoObject(movies: popularInfo.results),
                    categories: categoryInfo.genres
                )
            }
        
        return Output(
            loadingEvent: loading.asDriver(),
            errorEvent: error.asDriver(),
            getDataEvent: getAllDataEvent.asDriverOnErrorJustComplete()
        )
    }
}

extension HomeViewModel {
    struct Input {
        let getDataTrigger: Observable<Void>
    }
    
    struct Output {
        let loadingEvent: Driver<Bool>
        let errorEvent: Driver<Error>
        let getDataEvent: Driver<HomeDataObject>
    }
}

struct HomeDataObject {
    let movies: [InforObject]
    
    let categories: [CategoryObject]
}
