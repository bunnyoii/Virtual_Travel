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
    }

    func loadLandmarks() {
        if let url = Bundle.main.url(forResource: "landmarks", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                landmarks = try JSONDecoder().decode([Landmark].self, from: data)
            } catch {
                print("Error loading landmarks: \(error)")
            }
        }
    }
}
