//
//  LocationManager.swift
//  VirtualTravel
//
//  用于管理用户位置的类，基于 CoreLocation 框架实现
//
//  更新于 2024/12/21
//

import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var userLocation: CLLocation? // 用户当前位置
    
    private let locationManager = CLLocationManager() // CoreLocation 管理器
    
    override init() {
        super.init()
        locationManager.delegate = self // 设置代理
        locationManager.requestWhenInUseAuthorization() // 请求位置权限
        locationManager.startUpdatingLocation() // 开始更新位置
    }
    
    // 当位置更新时调用
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location // 更新用户位置
    }
}