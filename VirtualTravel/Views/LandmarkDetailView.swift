//
//  LandmarkDetailView.swift
//  VirtualTravel
//
//  SwiftUI 视图文件，用于显示单个地标的详细信息
//
//  Updated by 刘淑仪 on 2024/12/20
//

import SwiftUI
import CoreLocation

struct LandmarkDetailView: View {
    let landmark: Landmark
    @StateObject var locationManager = LocationManager()
    @State private var distance: Double?

    var body: some View {
        ScrollView {
            if let image = UIImage(named: landmark.image) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding()
            }

            VStack(alignment: .leading, spacing: 16) {
                Text(landmark.name)
                    .font(.title)
                Text(landmark.description)
                    .font(.body)

                // 显示距离
                if let distance = distance {
                    Text("Distance: \(String(format: "%.2f", distance / 1000)) km")
                        .font(.headline)
                        .padding(.top)
                }
            }
            .padding()
        }
        .navigationTitle(landmark.name)
        .onAppear {
            calculateDistance()
        }
    }

    // 计算当前位置到景点的距离
    func calculateDistance() {
        if let userLocation = locationManager.userLocation {
            let landmarkLocation = CLLocation(latitude: landmark.latitude, longitude: landmark.longitude)
            distance = userLocation.distance(from: landmarkLocation) // 计算距离
        }
    }
}
