
class PulseResultViewModel: ViewModelType {
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    func transform(input: Input) -> Output {
        return Output()
    }
}

struct PulseResultModel {
    let path: String
    
    let name: String
    
    let bpm: Int
}
