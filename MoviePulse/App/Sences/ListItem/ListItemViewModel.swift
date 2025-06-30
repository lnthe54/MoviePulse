import RxSwift
import RxCocoa

enum ListSectionType {
    case popular
    case category(categoryObject: CategoryObject)
    case others(title: String, items: [InfoObject])
    
    var title: String {
        switch self {
        case .popular:
            return ""
        case .category(let category):
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
    
    init(movieServices: MovieServices) {
        self.movieServices = movieServices
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
            switch sectionType {
            case .popular:
                return movieServices
                    .getMoviePopular(at: page, categoryId: 0)
                    .trackError(error)
                    .trackActivity(loading)
                    .map { Utils.transformToInfoObject(movies: $0.results) }
            case .category(let category):
                return movieServices
                    .getMovies(by: category.id, page: page)
                    .trackError(error)
                    .trackActivity(loading)
                    .map { Utils.transformToInfoObject(movies: $0.results) }
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

