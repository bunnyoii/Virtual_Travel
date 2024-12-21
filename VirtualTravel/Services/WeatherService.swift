//
//  WeatherService.swift
//  VirtualTravel
//
//  与 OpenWeatherMap API 进行交互，获取指定位置的天气信息
//
//  更新于 2024/12/21
//

import Foundation

class WeatherService {
    private let apiKey = "22125f68d3e9226d5d6191a7b3d9de00"
    private let baseURL = "https://api.openweathermap.org/data/2.5/weather"

    // 获取指定位置的天气信息
    // - Parameters:
    //   - latitude: 纬度
    //   - longitude: 经度
    //   - completion: 完成回调，返回结果或错误
    func fetchWeather(latitude: Double, longitude: Double, completion: @escaping (Result<Weather, Error>) -> Void) {
        // 构建请求 URL
        let urlString = "\(baseURL)?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"

        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "无效的 URL", code: -1, userInfo: nil)))
            return
        }

        // 发起网络请求
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("获取天气时出错: \(error)")
                completion(.failure(error))
                return
            }

            guard let data = data else {
                print("未收到数据")
                completion(.failure(NSError(domain: "没有数据", code: -1, userInfo: nil)))
                return
            }

            do {
                // 解析 API 响应
                let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                // 将响应数据转换为 Weather 对象
                let weather = Weather(
                    temperature: weatherResponse.main.temp,
                    condition: weatherResponse.weather.first?.main ?? "未知"
                )
                print("天气信息已获取: \(weather)")
                completion(.success(weather))
            } catch {
                print("解析天气数据时出错: \(error)")
                completion(.failure(error))
            }
        }

        task.resume()
    }
}

// 天气 API 响应结构体
struct WeatherResponse: Codable {
    let main: Main
    let weather: [WeatherInfo]

    struct Main: Codable {
        let temp: Double // 温度
    }

    struct WeatherInfo: Codable {
        let main: String // 天气状况
    }
}

// 天气结构体
struct Weather {
    let temperature: Double // 温度（摄氏度）
    let condition: String   // 天气状况
}