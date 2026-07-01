import SwiftUI

struct WeatherView: View {
    @StateObject private var viewModel = WeatherViewModel(service: WeatherFetchService())
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Input city name...", text: $viewModel.cityInput)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                Text(viewModel.cityLabel)
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                if let error = viewModel.errorMessage {
                    Text(error).foregroundColor(.red).font(.caption)
                }
                
                List(viewModel.weatherArray, id: \.dt_txt) { item in
                    WeatherRow(item: item)
                }
            }
            .navigationTitle("Weather")
        }
    }
}

struct WeatherRow: View {
    let item: ForecastItem

    var body: some View {
        HStack {
            if let icon = item.weather.first?.icon {
                AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 40, height: 40)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.dt_txt)
                    .font(.subheadline)
                    .fontWeight(.medium)

                HStack(spacing: 12) {
                    Label(String(format: "%.1f°C", item.main.temp_max), systemImage: "thermometer.high")
                    Label(String(format: "%.1f°C", item.main.temp_min), systemImage: "thermometer.low")
                }
                .font(.caption)

                HStack(spacing: 12) {
                    Label(String(format: "%.1f m/s", item.wind.speed), systemImage: "wind")

                    if let rain = item.rain?.threeHour {
                        Label(String(format: "%.1f mm", rain), systemImage: "drop.fill")
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
