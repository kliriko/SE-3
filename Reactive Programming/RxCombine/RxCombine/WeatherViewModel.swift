import Foundation
import Combine
import RxSwift
import RxCombine

final class WeatherViewModel: ObservableObject {
    @Published var weatherArray: [ForecastItem] = []
    @Published var cityInput: String = ""
    @Published var cityLabel: String = ""
    @Published var errorMessage: String? = nil

    private var cancellables = Set<AnyCancellable>()
    private let service: WeatherFetchService

    init(service: WeatherFetchService = WeatherFetchService()) {
        self.service = service
        setupCombineBindings()
    }
    private func setupCombineBindings() {
        $cityInput
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .filter { !$0.isEmpty }
            .map { [weak self] city -> AnyPublisher<(String, [ForecastItem]), Never> in
                guard let self = self else { return Just(("", [])).eraseToAnyPublisher() }
                return self.fetchWeatherPipeline(for: city)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (name, forecast) in
                self?.errorMessage = nil
                self?.cityLabel = name
                self?.weatherArray = forecast
            }
            .store(in: &cancellables)
    }

    private func fetchWeatherPipeline(for city: String) -> AnyPublisher<(String, [ForecastItem]), Never> {
        service.fetchCityWeather(for: city)
            .asObservable()
            .publisher
            .catch { [weak self] error -> Just<(String, [ForecastItem])> in
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                }
                return Just(("", []))
            }
            .eraseToAnyPublisher()
    }
}
