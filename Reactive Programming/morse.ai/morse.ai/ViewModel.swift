import Foundation
import RxSwift

final class ViewModel {
    enum Input {
        case dot
        case dash
        case skip
        case reset
    }

    let input = PublishSubject<Input>()
    let originalText = BehaviorSubject<String>(value: "")
    let translatedText = BehaviorSubject<String>(value: "")
    let alertTrigger = PublishSubject<Void>()

    private var currentMorse = ""
    private var resultText = ""

    private let bag = DisposeBag()

    init() {
        input.subscribe(onNext: { [weak self] event in
            self?.handle(event)
        }).disposed(by: bag)
    }

    private func handle(_ input: Input) {
        switch input {
        case .dot:
            currentMorse.append(".")
            originalText.onNext(currentMorse)
            
        case .dash:
            currentMorse.append("-")
            originalText.onNext(currentMorse)
            
        case .skip:
            if let char = morseToChar[currentMorse] {
                resultText.append(char)
            } else {
                alertTrigger.onNext(())
            }
            
            translatedText.onNext(resultText)
            currentMorse = ""
            originalText.onNext(currentMorse)

        case .reset:
            currentMorse = ""
            resultText = ""
            originalText.onNext("")
            translatedText.onNext("")
        }
    }
}
