import RxSwift
import RxCocoa

class DetailItemViewModel: ViewModelType {
    
    // MARK: - Properties
    private var movieServices: MovieServices
    
    init(movieServices: MovieServices) {
        self.movieServices = movieServices
    }
    
    func transform(input: Input) -> Output {
        return Output()
    }
}

extension DetailItemViewModel {
    struct Input {
        
    }
    
    struct Output {
        
    }
}

