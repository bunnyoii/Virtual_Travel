//
//  Landmark.swift
//  VirtualTravel
//
//  数据模型文件，用于定义地标（Landmark）的结构。
//  该文件定义了 `Landmark` 结构体，表示一个特定的地点或景点。
//  包括地标的名称、描述、坐标、图片和类别等属性。
//
//  更新于 2024/12/21
//

import Foundation
import MapKit

struct Landmark: Identifiable, Codable, Hashable {
    // 地标的唯一标识符
    let id: Int
    
    // 地标的名称
    let name: String
    
    // 地标的详细描述
    let description: String
    
    // 地标位置的纬度
    let latitude: Double
    
    // 地标位置的经度
    let longitude: Double
    
    // 表示地标的图片文件名或 URL
    let image: String

    // 地标的类别或类型
    let category: String

    // 计算属性，返回地标的坐标为 `CLLocationCoordinate2D` 对象。
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}