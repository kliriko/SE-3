//
//  ViewModel.swift
//  ReactiveCats
//
//  Created by Володимир on 02.02.2026.
//

import Foundation
import RxSwift
import UIKit

enum CatError: Error {
    case noURL, noPic, noStory, noDecoding
}

final class ViewModel {
    private let bag = DisposeBag()
    
    let image: BehaviorSubject<UIImage>
    let story: BehaviorSubject<String>
    let button: PublishSubject<Void>
    
    init(image: UIImage, story: String){
        self.image = BehaviorSubject(value: image)
        self.story = BehaviorSubject(value: story)
        self.button = PublishSubject()
        setup()
    }
        
    private func setup(){
        button
            .flatMapLatest { Single.zip(self.getRandomCatImage(), self.getRandomCatStory()) }
            .subscribe(onNext: { [weak self] in self?.image.onNext($0); self?.story.onNext($1) })
            .disposed(by: bag)
    }
    
    func getRandomCatImage() -> Single<UIImage> {
        return Single<UIImage>.create { single in
            guard let url = URL(string: "https://cataas.com/cat") else { single(.failure(CatError.noURL)) ; return Disposables.create() }

            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error { return single(.failure(error)) }

                guard
                    let data = data,
                    let image = UIImage(data: data)
                else { single(.failure(CatError.noPic)); return}
                
                return single(.success(image))
            }

            task.resume()
            
            return Disposables.create { task.cancel() }
        }
    }
    
    func getRandomCatStory() -> Single<String> {
        return Single<String>.create { single in
            guard let url = URL(string: "https://catfact.ninja/fact") else {
                single(.failure(CatError.noURL))
                return Disposables.create()
            }

            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error {
                    single(.failure(error))
                    return
                }

                guard let data = data else {
                    single(.failure(CatError.noStory))
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let fact = json["fact"] as? String {
                        single(.success(fact))
                    } else {
                        single(.failure(CatError.noDecoding))
                    }
                } catch {
                    single(.failure(CatError.noDecoding))
                }
            }

            task.resume()
            
            return Disposables.create { task.cancel() }
        }
    }
}
