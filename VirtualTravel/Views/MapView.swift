//
//  MapView.swift
//  VirtualTravel
//
//  SwiftUI 视图文件，用于在地图上显示地标的位置
//
//  更新于 2024/12/21
//

import SwiftUI
import MapKit

struct MapView: View {
    // 视图模型，管理地标数据和地图状态
    @ObservedObject var viewModel: LandmarkViewModel
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // 地图视图
            Map(
                coordinateRegion: $viewModel.mapRegion, // 地图的中心和缩放级别
                interactionModes: .all, // 允许所有交互模式
                showsUserLocation: true, // 显示用户位置
                annotationItems: viewModel.filteredLandmarks, // 使用过滤后的地标
                annotationContent: { landmark in
                    MapAnnotation(coordinate: landmark.coordinate) {
                        NavigationLink(destination: LandmarkDetailView(landmark: landmark, viewModel: viewModel)) {
                            VStack {
                                // 地标名称
                                Text(landmark.name)
                                    .font(.caption)
                                    .padding(4)
                                    .background(Color.white.opacity(0.8))
                                    .cornerRadius(4)
                                    .shadow(radius: 2)
                                if let image = UIImage(named: landmark.image) {
                                    // 地标图片
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                        .shadow(radius: 3)
                                }
                            }
                        }
                    }
                }
            )
            
            // 天气信息显示在右上角
            if let weather = viewModel.currentWeather {
                VStack {
                    Text("\(weather.condition)") // 天气状况
                        .font(.headline)
                        .padding(8)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(8)
                        .shadow(radius: 4)
                    
                    Text("\(Int(weather.temperature))°C") // 温度
                        .font(.headline)
                        .padding(8)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(8)
                        .shadow(radius: 4)
                }
                .padding(.trailing, 16) // 右边距
                .padding(.top, 16) // 上边距
            }
        }
    }
}