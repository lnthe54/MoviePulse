import RxSwift
import RxCocoa

enum ListSectionType {
    case heart(isPulse: Bool = false)
    case popular(title: String)
    case topRate(objectType: ObjectType)
    case trending(title: String, objectType: ObjectType)
    case onAir(title: String)
    case category(category: CategoryObject, objectType: ObjectType)
    case others(title: String, items: [InfoObject])
    
    var title: String {
        switch self {
        case .heart:
            return "Movies that raise your heart"
        case .popular(let title):
            return title
        case .topRate:
            return ""
        case .trending(let title, _):
            return title
        case .onAir(let title):
            return title
        case .category(let category, _):
            return category.name
        case .others(let title, _):
            return title
        }
    }
}

struct ListParameters {
    let sectionType: ListSectionType
    
    let page: Int
}

class ListItemViewModel: ViewModelType {
    
    // MARK: - Properties
    private var movieServices: MovieServices
    private var tvShowServices: TVShowServices
    
    init(movieServices: MovieServices, tvShowServices: TVShowServices) {
        self.movieServices = movieServices
        self.tvShowServices = tvShowServices
    }
    
    func transform(input: Input) -> Output {
        let loading = ActivityIndicator()
        let error = ErrorTracker()
        
        let getDataEvent = input.getDataTrigger
            .flatMapLatest(weak: self) { (self, params) in
                self.getData(
                    withloading: loading,
                    error: error,
                    sectionType: params.sectionType,
                    page: params.page
                )
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

extension ListItemViewModel {
    private func getData(
        withloading loading: ActivityIndicator,
        error: ErrorTracker,
        sectionType: ListSectionType,
        page: Int = 1
    ) -> Observable<[InfoObject]> {
        
        func handleMovie(_ observable: Observable<MovieContainerInfo>) -> Observable<[InfoObject]> {
            return observable
                .trackError(error)
                .trackActivity(loading)
                .map { Utils.transformToInfoObject(movies: $0.results) }
        }
        
        func handleTVShow(_ observable: Observable<TVShowContainerInfo>) -> Observable<[InfoObject]> {
            return observable
                .trackError(error)
                .trackActivity(loading)
                .map { Utils.transformToInfoObject(tvShows: $0.results) }
        }
        
        switch sectionType {
        case .heart:
            return handleMovie(movieServices.getTrending(at: page))
            
        case .popular:
            return handleMovie(movieServices.getMoviePopular(at: page, categoryId: 0))
            
        case .topRate(let type):
            switch type {
            case .movie:
                return handleMovie(movieServices.getMovieTopRate(at: page))
            case .tv:
                return handleTVShow(tvShowServices.getTVShowsTopRate(page: page))
            default:
                return Observable.just([])
            }
            
        case .trending(_, let type):
            switch type {
            case .movie:
                return handleMovie(movieServices.getTrending(at: page))
            case .tv:
                return handleTVShow(tvShowServices.getTrending(page: page))
            default:
                return Observable.just([])
            }
            
        case .onAir:
            return handleTVShow(tvShowServices.getTVShowsOnAir(page: page))
            
        case .category(let category, let type):
            switch type {
            case .movie:
                return handleMovie(movieServices.getMovies(by: category.id, page: page))
            case .tv:
                return handleTVShow(tvShowServices.getTVShowsByCategory(id: category.id, page: page))
            default:
                return Observable.just([])
            }
            
        case .others(_, let items):
            return Observable.just(items)
        }
    }
    
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

extension ListItemViewModel {
    struct Input {
        let getDataTrigger: Observable<ListParameters>
        let gotoDetailItemTrigger: Observable<InfoObject>
    }
    
    struct Output {
        let loadingEvent: Driver<Bool>
        let errorEvent: Driver<Error>
        let getDataEvent: Driver<[InfoObject]>
        let gotoDetailItemEvent: Driver<InfoDetailObject>
    }
}

