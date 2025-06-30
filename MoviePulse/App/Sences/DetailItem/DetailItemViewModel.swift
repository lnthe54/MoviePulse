import RxSwift
import RxCocoa

class DetailItemViewModel: ViewModelType {
    
    // MARK: - Properties
    private var movieServices: MovieServices
    
    init(movieServices: MovieServices) {
        self.movieServices = movieServices
    }
    
    func transform(input: Input) -> Output {
        let loading = ActivityIndicator()
        let error = ErrorTracker()
        
        let gotoDetailItemEvent = input.gotoDetailItemTrigger
            .flatMapLatest(weak: self) { (self, infoObject) in
                self.getDetailItemObject(withLoading: loading, error: error, infoObject: infoObject)
            }
        
        return Output(
            loadingEvent: loading.asDriver(),
            errorEvent: error.asDriver(),
            gotoDetailItemEvent: gotoDetailItemEvent.asDriverOnErrorJustComplete()
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
            
        default:
            return Observable.just(.empty())
        }
    }
}

extension DetailItemViewModel {
    struct Input {
        let gotoDetailItemTrigger: Observable<InfoObject>
    }
    
    struct Output {
        let loadingEvent: Driver<Bool>
        let errorEvent: Driver<Error>
        let gotoDetailItemEvent: Driver<InfoDetailObject>
    }
}

