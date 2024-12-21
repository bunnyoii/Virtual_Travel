//
//  WeatherService.swift
//  VirtualTravel
//
//  Created by 刘淑仪 on 2024/12/21.
//

import Foundation

class WeatherService {
    private let apiKey = "22125f68d3e9226d5d6191a7b3d9de00"
    private let baseURL = "https://api.openweathermap.org/data/2.5/weather"

    func fetchWeather(latitude: Double, longitude: Double, completion: @escaping (Result<Weather, Error>) -> Void) {
        let urlString = "\(baseURL)?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"

        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching weather: \(error)")
                completion(.failure(error))
                return
            }

            guard let data = data else {
                print("No data received")
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }

            do {
                let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                let weather = Weather(
                    temperature: weatherResponse.main.temp,
                    condition: weatherResponse.weather.first?.main ?? "Unknown"
                )
                print("Weather fetched: \(weather)")
                completion(.success(weather))
            } catch {
                print("Error decoding weather data: \(error)")
                completion(.failure(error))
            }
        }

        task.resume()
    }
}

struct WeatherResponse: Codable {
    let main: Main
    let weather: [WeatherInfo]

    struct Main: Codable {
        let temp: Double
    }

    struct WeatherInfo: Codable {
        let main: String
    }
}

struct Weather {
    let temperature: Double
    let condition: String
}
