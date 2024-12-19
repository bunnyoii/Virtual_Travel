//
//  MapView.swift
//  VirtualTravel
//
//  Created by 刘淑仪 on 2024/12/19.
//

import SwiftUI
import MapKit

struct MapView: View {
    // 位置管理器
    @StateObject var locationManager = LocationManager()
    
    // 地图显示区域
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // 默认位置（旧金山）
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    // 地标数据
    @StateObject var viewModel = LandmarkViewModel()

    var body: some View {
        Map(
            coordinateRegion: $region, // 绑定地图区域
            interactionModes: .all, // 允许所有交互
            showsUserLocation: true, // 显示用户位置
            annotationItems: viewModel.landmarks, // 传递地标数据
            annotationContent: { landmark in
                MapAnnotation(coordinate: landmark.coordinate) {
                    VStack {
                        // 显示地标名称
                        Text(landmark.name)
                            .font(.caption)
                            .padding(4)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(4)
                            .shadow(radius: 2)
                        
                        // 显示等比例缩小的图片
                        if let image = UIImage(named: landmark.image) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40) // 设置图片大小
                                .clipShape(Circle()) // 圆形图片
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .shadow(radius: 3)
                        }
                    }
                }
            }
        )
        .onAppear {
            // 更新地图区域为用户当前位置
            if let location = locationManager.userLocation?.coordinate {
                region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            }
        }
    }
}
