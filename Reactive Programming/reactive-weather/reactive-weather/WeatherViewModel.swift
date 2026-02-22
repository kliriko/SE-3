//
//  WeatherViewModel.swift
//  reactive-weather
//
//  Created by Володимир on 17.02.2026.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

protocol WeatherServiceType {
    func getCity(city: String) -> Single<City>
    func getForecast(lat: Double, lon: Double) -> Single<[ForecastItem]>
}

class WeatherViewModel: NSObject, UITableViewDataSource{
    var weatherArray = BehaviorRelay<[ForecastItem]>(value: [])
    var bombasticCityInput = BehaviorRelay<String>(value: "")
    var pretenciousCityLabel = BehaviorRelay<String>(value: "")
    var errorMessage = BehaviorRelay<String?>(value: nil)
    var bag = DisposeBag()
    var service: WeatherServiceType
    private let scheduler: SchedulerType
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weatherArray.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        cell.configure(with: weatherArray.value[indexPath.row])
        return cell
    }
    
    init(
        service: WeatherServiceType,
        scheduler: SchedulerType = MainScheduler.instance
    ) {
        self.service = service
        self.scheduler = scheduler
        super.init()
        setup()
    }

    
    func setup() {
        bombasticCityInput
            .observe(on: scheduler)
            .filter { !$0.isEmpty }
            .flatMapLatest { [weak self] in self?.searchWeather(for: $0) ?? .empty() }
            .bind(to: weatherArray)
            .disposed(by: bag)
    }

    private func searchWeather(for city: String) -> Observable<[ForecastItem]> {
        return service.getCity(city: city)
            .subscribe(on: scheduler)
            .do(onSuccess: { [weak self] in self?.pretenciousCityLabel.accept($0.name) })
            .flatMap { [weak self] in self?.service.getForecast(lat: $0.latitude, lon: $0.longitude) ?? .error(WeatherError.geocodingFailed) }
            .asObservable()
            .catch { [weak self] error in
                self?.handleError(error)
                return .just([])
            }
    }

    func handleError(_ error: Error) {
        if let weatherError = error as? WeatherError {
            errorMessage.accept(weatherError.localizedDescription)
        } else {
            errorMessage.accept(error.localizedDescription)
        }
    }
}

enum WeatherError: LocalizedError {
    case cityNotFound
    case noDataReceived
    case invalidURL
    case geocodingFailed
    
    
    var errorDescription: String? {
        switch self {
        case .cityNotFound:
            return "City not found"
        case .noDataReceived:
            return "No data received"
        case .invalidURL:
            return "Invalid city name"
        case .geocodingFailed:
            return "Geocoding failed"
        }
    }
}
