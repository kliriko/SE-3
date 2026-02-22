//
//  ViewController.swift
//  ReactiveCats
//
//  Created by Володимир on 02.02.2026.
//

import UIKit
import RxSwift

class ViewController: UIViewController {
    @IBOutlet weak var storyView: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var button: UIButton!
    
    private let vm = ViewModel(
            image: UIImage(systemName: "photo") ?? UIImage(),
            story: "Tap to load cat facts!"
        )
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        Observable.combineLatest(vm.image, vm.story)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] image, story in self?.imageView.image = image; self?.storyView.text = story })
            .disposed(by: bag)
    }
    
    @IBAction func generate(_ sender: Any) {
        storyView.text = "Loading..."
        imageView.image = UIImage(resource: .loading)
        self.vm.button.onNext(())
    }
}

