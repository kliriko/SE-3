import Foundation
import RxSwift

class WeatherFetchService {
    func getForecast(lat: Double, lon: Double) -> Single<[ForecastItem]> {
        return Single<[ForecastItem]>.create { single in
            guard let url = URL(string: "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&units=metric&appid=0e6db472ee2f86f3b5374e63cd5218c4") else {
                single(.failure(WeatherError.invalidURL))
                return Disposables.create()
            }

            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error { single(.failure(error)); return }
                guard let data = data else { single(.failure(WeatherError.noDataReceived)); return }
                
                do {
                    let response = try JSONDecoder().decode(ForecastResponse.self, from: data)
                    single(.success(response.list))
                } catch {
                    single(.failure(error))
                }
            }
            task.resume()
            return Disposables.create { task.cancel() }
        }
    }

    func fetchCityWeather(for city: String) -> Single<(String, [ForecastItem])> {
        getCity(city: city).flatMap { cityObj in
            self.getForecast(lat: cityObj.latitude, lon: cityObj.longitude)
                .map { forecast in (cityObj.name, forecast) }
        }
    }

    func getCity(city: String) -> Single<City> {
        return Single<City>.create { [weak self] single in
            guard self != nil else { single(.failure(WeatherError.invalidURL)); return Disposables.create() }

            guard let url = URL(string: "https://api.api-ninjas.com/v1/geocoding?city=\(city)") else {
                single(.failure(WeatherError.invalidURL))
                return Disposables.create()
            }

            var request = URLRequest(url: url)
            request.setValue("uAKL9U1cApG4EZCIwGfK2x5hhLu8iDgRrfWAVaMy", forHTTPHeaderField: "X-Api-Key")

            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    single(.failure(error))
                    return
                }

                guard let data = data else {
                    single(.failure(WeatherError.noDataReceived))
                    return
                }

                do {
                    let results = try JSONDecoder().decode([City].self, from: data)
                    guard let first = results.first else {
                        single(.failure(WeatherError.cityNotFound))
                        return
                    }
                    single(.success(results.first!))
                } catch {
                    single(.failure(error))
                }
            }

            task.resume()
            return Disposables.create { task.cancel() }
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
