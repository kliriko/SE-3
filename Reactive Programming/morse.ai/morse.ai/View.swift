//
//  ViewController.swift
//  morse.ai
//
//  Created by Володимир on 26.01.2026.
//

import UIKit
import RxSwift

class ViewController: UIViewController {
    @IBOutlet weak var dotButton: UIButton!
    @IBOutlet weak var dashButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var originalInputLabel: UILabel!
    @IBOutlet weak var translatedTextLabel: UILabel!
    
    private var vm: ViewModel = ViewModel()
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        vm.originalText
            .subscribe(onNext: { [weak self] text in
                self?.originalInputLabel.text = "morse: \(text)"
            })
            .disposed(by: bag)
        
        vm.translatedText
            .subscribe(onNext: { [weak self] text in
                self?.translatedTextLabel.text = "human: \(text)"
            })
            .disposed(by: bag)
        
        vm.alertTrigger
            .subscribe(onNext: { [weak self] in
                let alert = UIAlertController(title: "Invalid Morse", message: "The entered Morse code is not recognized.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            })
            .disposed(by: bag)
    }
    
    @IBAction func dotTap(_ sender: Any) { vm.input.onNext(.dot) }
    @IBAction func dashTap(_ sender: Any) { vm.input.onNext(.dash) }
    @IBAction func skipTap(_ sender: Any) { vm.input.onNext(.skip) }
    @IBAction func resetTap(_ sender: Any) { vm.input.onNext(.reset) }
}
