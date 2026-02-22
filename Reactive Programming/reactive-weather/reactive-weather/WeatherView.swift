//
//  ViewController.swift
//  reactive-weather
//
//  Created by Володимир on 10.02.2026.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa

class ViewController: UIViewController {
    @IBOutlet weak var magnificentTable: UITableView!
    @IBOutlet weak var bombasticCityInput: UITextField!
    @IBOutlet weak var pretenciousCityLabel: UILabel!
    var bag = DisposeBag()
    
    var viewModel = WeatherViewModel(service: WeatherFetchService())

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    func setup() {
        bombasticCityInput.rx.text.orEmpty
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: viewModel.bombasticCityInput)
            .disposed(by: bag)

        viewModel.pretenciousCityLabel
            .asDriver(onErrorJustReturn: "")
            .drive(pretenciousCityLabel.rx.text)
            .disposed(by: bag)

        viewModel.weatherArray
            .asDriver(onErrorJustReturn: [])
            .drive(magnificentTable.rx.items(cellIdentifier: "cell", cellType: TableViewCell.self)) { row, element, cell in
                cell.configure(with: element)
            }
            .disposed(by: bag)
    }
}
