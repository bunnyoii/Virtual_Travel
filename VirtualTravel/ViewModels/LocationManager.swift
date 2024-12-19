//
//  LocationManager.swift
//  VirtualTravel
//
//  Created by 刘淑仪 on 2024/12/19.
//

import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var userLocation: CLLocation?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization() // 请求位置权限
        locationManager.startUpdatingLocation() // 开始更新位置
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location // 更新用户位置
    }
}
