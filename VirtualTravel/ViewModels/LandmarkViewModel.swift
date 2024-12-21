//
//  LandmarkViewModel.swift
//  VirtualTravel
//
//  SwiftUI 视图模型文件，用于管理地标数据和地图区域的状态
//
//  更新于 2024/12/21
//

import Foundation
import CoreLocation
import Combine
import MapKit

class LandmarkViewModel: ObservableObject {
    @Published var landmarks: [Landmark] = [] // 所有地标数据
    @Published var filteredLandmarks: [Landmark] = [] // 用于存储过滤后的地标
    @Published var searchText: String = "" // 搜索框的输入内容
    @Published var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.8719, longitude: -122.2585), // 默认位置：加州伯克利大学
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01) // 缩放级别
    )
    @Published var userLocation: CLLocation? // 用户当前位置
    @Published var currentWeather: Weather? // 当前天气信息
    
    private let locationManager = LocationManager() // 位置管理器
    private var cancellables = Set<AnyCancellable>() // 用于存储 Combine 的订阅
    private let weatherService = WeatherService() // 天气服务
    
    // 默认的加州伯克利大学的经纬度
    private let defaultLocation = CLLocation(latitude: 37.8719, longitude: -122.2585)
    
    // 获取所有类别的唯一列表
    var categories: [String] {
        Array(Set(landmarks.map { $0.category })).sorted()
    }
    
    init() {
        loadLandmarks() // 初始化时加载地标数据
        
        // 监听用户位置的变化，并更新地图中心
        locationManager.$userLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (location: CLLocation?) in
                if let location = location {
                    // 如果获取到用户位置，更新地图中心为当前位置
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
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main) // 延迟 0.5 秒处理地图区域变化
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
    
    // 加载地标数据
    func loadLandmarks() {
        if let url = Bundle.main.url(forResource: "landmarks", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                landmarks = try JSONDecoder().decode([Landmark].self, from: data)
                filteredLandmarks = landmarks // 初始化时，filteredLandmarks 与 landmarks 相同
            } catch {
                print("加载地标数据时出错: \(error)")
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
                    print("获取天气信息时出错: \(error)")
                }
            }
        }
    }
}