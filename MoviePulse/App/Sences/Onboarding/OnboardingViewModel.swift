import RxSwift
import RxCocoa

class OnboardingViewModel: ViewModelType {
    
    func transform(input: Input) -> Output {
        let getDataEvent = input.getDataTrigger
            .flatMapFirst(weak: self) { (self, _) in
                return self.initOnboardingInfo()
            }
        
        return Output(
            getDataEvent: getDataEvent.asDriverOnErrorJustComplete()
        )
    }
}

extension OnboardingViewModel {
    private func initOnboardingInfo() -> Observable<[OnboardingInfo]> {
        var onboardings: [OnboardingInfo] = []
        
        onboardings.append(OnboardingInfo(id: 1, title: "Your emotions are the map", content: "Let your mood guide your movie journey"))
        onboardings.append(OnboardingInfo(id: 2, title: "Touch the camera to record pulse", content: "Measure how a movie touches your heart"))
        onboardings.append(OnboardingInfo(id: 3, title: "Ready to feel the pulse?", content: "We’ll need camera access to measure your heartbeat"))
        
        return Observable.just(onboardings)
    }
}

extension OnboardingViewModel {
    struct Input {
        let getDataTrigger: Observable<Void>
    }
    
    struct Output {
        let getDataEvent: Driver<[OnboardingInfo]>
    }
}

struct OnboardingInfo {
    let id: Int
    
    let title: String
    
    let content: String
}
