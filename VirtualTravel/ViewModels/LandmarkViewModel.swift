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
    @Published var filteredLandmarks: [Landmark] = [] // 新增：用于存储过滤后的地标
    @Published var searchText: String = "" // 新增：搜索框的输入内容
    @Published var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    @Published var userLocation: CLLocation?

    private let locationManager = LocationManager()
    private var cancellables = Set<AnyCancellable>()

    init() {
        loadLandmarks()
        locationManager.$userLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (location: CLLocation?) in
                if let location = location {
                    self?.mapRegion = MKCoordinateRegion(center: location.coordinate, span: self?.mapRegion.span ?? MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
                }
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
}