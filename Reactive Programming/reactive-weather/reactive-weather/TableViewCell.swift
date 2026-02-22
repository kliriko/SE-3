//
//  TableViewCell.swift
//  reactive-weather
//
//  Created by Володимир on 10.02.2026.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa

class TableViewCell: UITableViewCell {
    @IBOutlet weak var vibeDay: UILabel!
    @IBOutlet weak var boringDayTemp: UILabel!
    @IBOutlet weak var cheekyNightTemp: UILabel!
    @IBOutlet weak var moodyRain: UILabel!
    @IBOutlet weak var crazyWind: UILabel!
    @IBOutlet weak var nuclearImage: UIImageView!
    
    var viewModel = TableCellViewModel()
    private var bag = DisposeBag()

    func configure(with item: ForecastItem) {
        viewModel.update(with: item)
        bindViewModel()
    }

    private func bindViewModel() {
        bag = DisposeBag()

        viewModel.day
            .bind(to: vibeDay.rx.text)
            .disposed(by: bag)

        viewModel.dayTemp
            .bind(to: boringDayTemp.rx.text)
            .disposed(by: bag)

        viewModel.nightTemp
            .bind(to: cheekyNightTemp.rx.text)
            .disposed(by: bag)
        
        viewModel.rain
            .bind(to: moodyRain.rx.text)
            .disposed(by: bag)
        
        viewModel.wind
            .bind(to: crazyWind.rx.text)
            .disposed(by: bag)
        
        viewModel.iconURL
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] url in
                DispatchQueue.global().async {
                    guard let data = try? Data(contentsOf: url),
                          let image = UIImage(data: data) else { return }
                    DispatchQueue.main.async {
                        self?.nuclearImage.image = image
                    }
                }
            })
            .disposed(by: bag)
    }
}

class TableCellViewModel {
    var day = BehaviorRelay<String>(value: "")
    var dayTemp = BehaviorRelay<String>(value: "")
    var nightTemp = BehaviorRelay<String>(value: "")
    var wind = BehaviorRelay<String>(value: "")
    var rain = BehaviorRelay<String>(value: "")
    var iconURL = BehaviorRelay<URL?>(value: nil)

    func update(with item: ForecastItem) {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let date = inputFormatter.date(from: item.dt_txt) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "MMM d"
            day.accept(outputFormatter.string(from: date))
        } else {
            day.accept(item.dt_txt) 
        }
        
        dayTemp.accept("Day temp: " + String(format: "%.1f°C", item.main.temp_max))
        nightTemp.accept("Night temp: " + String(format: "%.1f°C", item.main.temp_min))
        
        wind.accept("Wind: " + String(format: "%.1f m/s", item.wind.speed))
        if let mm = item.rain?.threeHour {
            rain.accept(String(format: "%.1f mm", mm))
        } else {
            rain.accept("No rain")
        }
        
        if let iconCode = item.weather.first?.icon {
            iconURL.accept(URL(string: "https://openweathermap.org/img/wn/\(iconCode)@2x.png"))
        }
    }
}
