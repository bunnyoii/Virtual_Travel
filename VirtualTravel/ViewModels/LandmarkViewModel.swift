//
//  LandmarkViewModel.swift
//  VirtualTravel
//
//  SwiftUI 视图模型文件，用于管理地标数据和地图区域的状态
//
//  Updated by 刘淑仪 on 2024/12/20
//

import Foundation
import CoreLocation
import Combine
import MapKit

class LandmarkViewModel: ObservableObject {
    @Published var landmarks: [Landmark] = []
    @Published var filteredLandmarks: [Landmark] = [] // 用于存储过滤后的地标
    @Published var searchText: String = "" // 搜索框的输入内容
    @Published var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.8719, longitude: -122.2585), // 默认位置：加州伯克利大学
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01) // 缩放级别
    )
    @Published var userLocation: CLLocation?
    @Published var currentWeather: Weather? // 当前天气信息

    private let locationManager = LocationManager()
    private var cancellables = Set<AnyCancellable>()
    private let weatherService = WeatherService() // 天气服务

    // 默认的加州伯克利大学的经纬度
    private let defaultLocation = CLLocation(latitude: 37.8719, longitude: -122.2585)

    init() {
        loadLandmarks()
        locationManager.$userLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (location: CLLocation?) in
                if let location = location {
                    self?.mapRegion = MKCoordinateRegion(center: location.coordinate, span: self?.mapRegion.span ?? MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
                } else {
                    // 如果无法获取用户位置，使用默认的加州伯克利大学位置
                    self?.mapRegion = MKCoordinateRegion(center: self?.defaultLocation.coordinate ?? CLLocationCoordinate2D(latitude: 37.8719, longitude: -122.2585), span: self?.mapRegion.span ?? MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
                }
                self?.fetchWeather() // 更新天气信息
            }
            .store(in: &cancellables)

        // 监听 mapRegion 的变化，并更新天气信息
        $mapRegion
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.fetchWeather()
            }
            .store(in: &cancellables)

        // 监听 searchText 的变化，并过滤地标
        $searchText
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main) // 延迟 0.5 秒处理搜索
            .map { searchText in
                searchText.isEmpty ? self.landmarks : self.landmarks.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
            }
            .assign(to: &$filteredLandmarks)
    }

    func loadLandmarks() {
        if let url = Bundle.main.url(forResource: "landmarks", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                landmarks = try JSONDecoder().decode([Landmark].self, from: data)
                filteredLandmarks = landmarks // 初始化时，filteredLandmarks 与 landmarks 相同
            } catch {
                print("Error loading landmarks: \(error)")
            }
        }
    }

    // 获取当前位置的天气信息
    private func fetchWeather() {
        let latitude = mapRegion.center.latitude
        let longitude = mapRegion.center.longitude

        weatherService.fetchWeather(latitude: latitude, longitude: longitude) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let weather):
                    self?.currentWeather = weather
                case .failure(let error):
                    print("Error fetching weather: \(error)")
                }
            }
        }
    }
}
