//
//  GeoapifyService.swift
//  VirtualTravel
//
//  与Geoapify API 进行交互，获取附近的地点信息用于推荐旅馆和餐馆
//
//  更新于 2024/12/21
//

import Foundation

class GeoapifyService {
    private let apiKey = "a14a3f3ff8d84aafbbdd3a397d8141b5"
    private let baseURL = "https://api.geoapify.com/v2/places"

    // 获取指定位置附近的地点（例如餐厅或旅馆）
    // - Parameters:
    //   - latitude: 纬度
    //   - longitude: 经度
    //   - radius: 搜索半径（以米为单位）
    //   - type: 地点类型（"catering" 表示餐厅，"accommodation" 表示旅馆）
    //   - completion: 完成回调，返回结果或错误
    func fetchNearbyPlaces(latitude: Double, longitude: Double, radius: Double, type: String, completion: @escaping (Result<[Place], Error>) -> Void) {
        // 构建请求 URL
        let urlString = "\(baseURL)?categories=\(type)&filter=circle:\(longitude),\(latitude),\(radius)&bias=proximity:\(longitude),\(latitude)&limit=10&apiKey=\(apiKey)"

        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "无效的 URL", code: -1, userInfo: nil)))
            return
        }

        // 发起网络请求
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "没有数据", code: -1, userInfo: nil)))
                return
            }

            do {
                // 解析 API 响应
                let placesResponse = try JSONDecoder().decode(GeoapifyResponse.self, from: data)
                // 将响应数据转换为 Place 对象
                let places = placesResponse.features.map { Place(id: $0.properties.place_id, name: $0.properties.name, address: $0.properties.address_line2, latitude: $0.geometry.coordinates[1], longitude: $0.geometry.coordinates[0]) }
                completion(.success(places))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
}

// Geoapify API 响应结构体
struct GeoapifyResponse: Codable {
    let features: [Feature]

    struct Feature: Codable {
        let properties: Properties
        let geometry: Geometry

        struct Properties: Codable {
            let place_id: String
            let name: String
            let address_line2: String
        }

        struct Geometry: Codable {
            let coordinates: [Double]
        }
    }
}

// 地点结构体
struct Place: Identifiable {
    let id: String
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
}