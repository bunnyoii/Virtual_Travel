//
//  GeoapifyService.swift
//  VirtualTravel
//
//  Created by 刘淑仪 on 2024/12/21.
//

import Foundation

class GeoapifyService {
    private let apiKey = "a14a3f3ff8d84aafbbdd3a397d8141b5" // 替换为你的 Geoapify API Key
    private let baseURL = "https://api.geoapify.com/v2/places"

    // 获取附近的地点（餐厅或旅馆）
    func fetchNearbyPlaces(latitude: Double, longitude: Double, radius: Double, type: String, completion: @escaping (Result<[Place], Error>) -> Void) {
        let urlString = "\(baseURL)?categories=\(type)&filter=circle:\(longitude),\(latitude),\(radius)&bias=proximity:\(longitude),\(latitude)&limit=10&apiKey=\(apiKey)"

        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }

            do {
                let placesResponse = try JSONDecoder().decode(GeoapifyResponse.self, from: data)
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
