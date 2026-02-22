import XCTest
import RxSwift
import RxTest
import RxBlocking
@testable import reactive_weather
internal import RxRelay

// MARK: - Mock Service

final class MockWeatherService: WeatherServiceType {
    var geocodeResult: Single<City> = .error(WeatherError.cityNotFound)
    var fetchResult: Single<[ForecastItem]> = .error(WeatherError.noDataReceived)

    func getCity(city: String) -> Single<City> { geocodeResult }
    func getForecast(lat: Double, lon: Double) -> Single<[ForecastItem]> { fetchResult }
}

// MARK: - Tests

final class WeatherViewModelTests: XCTestCase {

    var vm: WeatherViewModel!
    var service: MockWeatherService!
    var bag: DisposeBag!

    override func setUp() {
        super.setUp()
        service = MockWeatherService()
        vm = WeatherViewModel(service: service)
        bag = DisposeBag()
    }

    override func tearDown() {
        bag = nil
        vm = nil
        service = nil
        super.tearDown()
    }

    // Test 1. Empty input should not emit an event.
    func test_emptyInput_noEmission() {
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver([ForecastItem].self)

      
        vm = WeatherViewModel(service: service, scheduler: scheduler)

        vm.weatherArray
            .skip(1)
            .subscribe(observer)
            .disposed(by: bag)

        scheduler.scheduleAt(10) {
            self.vm.bombasticCityInput.accept("")
        }

        scheduler.start()

        XCTAssertTrue(observer.events.isEmpty,
                      "Empty string should be filtered and produce no weather events")
    }

    // Test 2. Valid search
    func test_success_emitsWeather() {
        let city = City(name: "Kyiv", longitude: 1, latitude: 1)
        let item = ForecastItem(
            dt: 1,
            main: .init(temp_min: 0, temp_max: 1),
            weather: [.init(icon: "01")],
            wind: .init(speed: 1),
            dt_txt: "",
            rain: nil
        )

        service.geocodeResult = .just(city)
        service.fetchResult = .just([item])

        vm.bombasticCityInput.accept("Kyiv")

        let result = try? vm.weatherArray
            .skip(1)
            .filter { !$0.isEmpty }
            .toBlocking(timeout: 1)
            .first()

        XCTAssertEqual(result, [item])
    }

    // Test 3. Correct geocoding error handling
    func test_geocodeError_emitsMessage() {
        service.geocodeResult = .error(WeatherError.cityNotFound)

        vm.bombasticCityInput.accept("fail")

        let message = try? vm.errorMessage
            .skip(1)
            .compactMap { $0 }
            .toBlocking(timeout: 1)
            .first()

        XCTAssertEqual(message, "City not found")
    }

    // Test 4. Correct forecast fetch error handling.
    func test_fetchError_emitsMessage() throws {
        let city = City(name: "Kyiv", longitude: 1, latitude: 1)

        service.geocodeResult = .just(city)
        service.fetchResult = .error(WeatherError.noDataReceived)

        vm.bombasticCityInput.accept("Kyiv")

        let message = try vm.errorMessage
            .skip(1)
            .compactMap { $0 }
            .toBlocking(timeout: 1)
            .first()

        XCTAssertEqual(message, "No data received")
    }

    // Test 5. Only the latest data is shown
    func test_latestInput_wins() {
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(String.self)

        let oldCity = City(name: "Old", longitude: 0, latitude: 0)
        let newCity = City(name: "New", longitude: 1, latitude: 1)

        service.fetchResult = .just([])

        vm = WeatherViewModel(service: service, scheduler: scheduler)

        vm.pretenciousCityLabel
            .skip(1)
            .subscribe(observer)
            .disposed(by: bag)

        scheduler.scheduleAt(10) {
            self.service.geocodeResult = scheduler
                .createColdObservable([.next(20, oldCity)])
                .asSingle()
            self.vm.bombasticCityInput.accept("Old")
        }

        scheduler.scheduleAt(15) {
            self.service.geocodeResult = .just(newCity)
            self.vm.bombasticCityInput.accept("New")
        }

        scheduler.start()
        XCTAssertEqual(observer.events.map { $0.value.element }, ["New"])
    }

    // Test 6. Successful label update on city name fetch
    func test_labelUpdates() throws {
        let city = City(name: "Paris", longitude: 0, latitude: 0)

        service.geocodeResult = .just(city)
        service.fetchResult = .just([])

        vm.bombasticCityInput.accept("Paris")

        let label = try vm.pretenciousCityLabel
            .skip(1)
            .toBlocking(timeout: 1)
            .first()

        XCTAssertEqual(label, "Paris")
    }

    // Test 7. TableView is synced with actual data
    func test_tableRowsReflectState() {
        vm.weatherArray.accept([
            ForecastItem(
                dt: 1,
                main: .init(temp_min: 0, temp_max: 1),
                weather: [.init(icon: "")],
                wind: .init(speed: 0),
                dt_txt: "",
                rain: nil
            )
        ])

        let rows = vm.tableView(UITableView(), numberOfRowsInSection: 0)

        XCTAssertEqual(rows, 1)
    }

    // Test 8. Rain decoding success
    func test_rainDecoding() throws {
        let json = #"{"3h":2.5}"#.data(using: .utf8)!
        let rain = try JSONDecoder().decode(Rain.self, from: json)

        XCTAssertEqual(rain.threeHour, 2.5)
    }

   // Test 9. Expected error message
    func test_emptyGeocodeError() throws {
        service.geocodeResult = .error(WeatherError.cityNotFound)
        vm.bombasticCityInput.accept("???")

        let message = try vm.errorMessage
            .skip(1)
            .compactMap { $0 }
            .toBlocking(timeout: 1)
            .first()

        XCTAssertEqual(message, "City not found")
    }

    // Test 10. Pasting behaves like typing.
    func test_pasteTriggersSearch() throws {
        let city = City(name: "Rome", longitude: 1, latitude: 1)

        service.geocodeResult = .just(city)
        service.fetchResult = .just([])

        vm.bombasticCityInput.accept("Rome")

        let label = try vm.pretenciousCityLabel
            .skip(1)
            .toBlocking(timeout: 1)
            .first()

        XCTAssertEqual(label, "Rome")
    }

    // Test 11. Rapid input
    func test_rapidInput_lastWins() throws {
        let city = City(name: "Berlin", longitude: 1, latitude: 1)

        service.geocodeResult = .just(city)
        service.fetchResult = .just([])

        vm.bombasticCityInput.accept("B")
        vm.bombasticCityInput.accept("Be")
        vm.bombasticCityInput.accept("Berlin")

        // Wait for the last label to stabilise.
        let label = try vm.pretenciousCityLabel
            .skip(1)
            .toBlocking(timeout: 1)
            .first()

        XCTAssertEqual(label, "Berlin")
    }

    // Test 12. Unknown error
    func test_unknownError_setsMessage() {
        vm.handleError(NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Something went wrong"]))

        XCTAssertNotNil(vm.errorMessage.value)
    }
}
