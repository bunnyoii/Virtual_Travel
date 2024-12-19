//
//  Landmark.swift
//  VirtualTravel
//
//  Created by 刘淑仪 on 2024/12/19.
//

import Foundation
import MapKit

struct Landmark: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let description: String
    let latitude: Double
    let longitude: Double
    let image: String // 图片文件名

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
