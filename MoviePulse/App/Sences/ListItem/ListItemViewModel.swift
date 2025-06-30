import RxSwift
import RxCocoa

enum ListSectionType {
    case popular
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
        
        return Output(
            loadingEvent: loading.asDriver(),
            errorEvent: error.asDriver(),
            getDataEvent: getDataEvent.asDriverOnErrorJustComplete()
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
                return self.movieServices
                    .getMoviePopular(at: page, categoryId: 0)
                    .trackError(error)
                    .trackActivity(loading)
                    .map { return Utils.transformToInfoObject(movies: $0.results) }
            default:
                return Observable.just([])
            }
        }
}

extension ListItemViewModel {
    struct Input {
        let getDataTrigger: Observable<ListParameters>
    }
    
    struct Output {
        let loadingEvent: Driver<Bool>
        let errorEvent: Driver<Error>
        let getDataEvent: Driver<[InfoObject]>
    }
}

