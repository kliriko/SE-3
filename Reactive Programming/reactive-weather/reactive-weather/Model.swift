//
//  Model.swift
//  reactive-weather
//
//  Created by Володимир on 10.02.2026.
//

import Foundation

struct ForecastResponse: Codable {
    let list: [ForecastItem]
}

struct ForecastItem: Codable, Equatable {
    let dt: Int
    let main: MainWeather
    let weather: [WeatherDescription]
    let wind: Wind
    let dt_txt: String
    let rain: Rain?
}

struct Rain: Codable, Equatable {
    let threeHour: Double?
    
    enum CodingKeys: String, CodingKey {
        case threeHour = "3h"
    }
}

struct MainWeather: Codable, Equatable {
    let temp_min: Double
    let temp_max: Double
}

struct WeatherDescription: Codable, Equatable {
    let icon: String
}

struct Wind: Codable, Equatable {
    let speed: Double
}

struct City: Codable, Equatable {
    let name: String
    let longitude: Double
    let latitude: Double
}
