//
//  LandmarkDetailView.swift
//  VirtualTravel
//
//  SwiftUI 视图文件，用于显示单个地标的详细信息
//
//  Updated by 刘淑仪 on 2024/12/20
//

import SwiftUI
import MapKit

struct LandmarkDetailView: View {
    let landmark: Landmark
    @StateObject var locationManager = LocationManager()
    @State private var distance: Double?
    @ObservedObject var viewModel: LandmarkViewModel // 引用 ViewModel
    @AppStorage("favoriteLandmarksData") private var favoriteLandmarksData: Data? // 存储为 Data 类型
    @State private var favoriteLandmarks: [Int] = [] // 使用 @State 存储可变的收藏列表

    // 假设相似景点的 id 列表
    let similarLandmarkIds: [Int] = [1, 2, 4] // 这里可以根据实际逻辑动态生成

    var body: some View {
        ScrollView {
            // 景点图片
            if let image = UIImage(named: landmark.image) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding()
            } else {
                Text("图片加载失败")
                    .foregroundColor(.red)
                    .padding()
            }

            VStack(alignment: .leading, spacing: 16) {
                // 景点名称
                Text(landmark.name)
                    .font(.title)

                // 景点描述
                Text(landmark.description)
                    .font(.body)

                // 显示距离
                if let distance = distance {
                    Text("Distance: \(String(format: "%.2f", distance / 1000)) km")
                        .font(.headline)
                        .padding(.top)
                }

                // 导航按钮
                Button(action: {
                    openMapsForNavigation()
                }) {
                    Text("导航")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top)

                // 收藏按钮
                Button(action: {
                    if favoriteLandmarks.contains(landmark.id) {
                        favoriteLandmarks.removeAll { $0 == landmark.id }
                    } else {
                        favoriteLandmarks.append(landmark.id)
                    }
                    saveFavoriteLandmarks() // 保存更新后的收藏列表
                }) {
                    Image(systemName: favoriteLandmarks.contains(landmark.id) ? "heart.fill" : "heart")
                        .foregroundColor(.red)
                        .font(.title)
                }
                .padding(.top)

                // 相似景点推荐
                VStack(alignment: .leading, spacing: 8) {
                    Text("相似景点推荐")
                        .font(.headline)
                        .padding(.top)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(similarLandmarks(), id: \.id) { similarLandmark in
                                NavigationLink(destination: LandmarkDetailView(landmark: similarLandmark, viewModel: viewModel)) {
                                    VStack {
                                        if let image = UIImage(named: similarLandmark.image) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 80, height: 80)
                                                .clipShape(Circle())
                                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                                .shadow(radius: 3)
                                        } else {
                                            Text("图片加载失败")
                                                .foregroundColor(.red)
                                                .frame(width: 80, height: 80)
                                        }
                                        Text(similarLandmark.name)
                                            .font(.caption)
                                            .foregroundColor(.black)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.top)
            }
            .padding()
        }
        .navigationTitle(landmark.name)
        .onAppear {
            loadFavoriteLandmarks() // 加载收藏列表
            calculateDistance()
            DispatchQueue.main.async {
                updateMapCenter() // 延迟更新地图中心点
            }
        }
    }

    // 加载收藏列表
    func loadFavoriteLandmarks() {
        if let data = favoriteLandmarksData,
           let ids = try? JSONDecoder().decode([Int].self, from: data) {
            favoriteLandmarks = ids
        }
    }

    // 保存收藏列表
    func saveFavoriteLandmarks() {
        if let data = try? JSONEncoder().encode(favoriteLandmarks) {
            favoriteLandmarksData = data
        }
    }
    // 计算当前位置到景点的距离
        func calculateDistance() {
            if let userLocation = locationManager.userLocation {
                let landmarkLocation = CLLocation(latitude: landmark.latitude, longitude: landmark.longitude)
                distance = userLocation.distance(from: landmarkLocation) // 计算距离
            }
        }

        // 更新地图中心点为当前景点的经纬度
        func updateMapCenter() {
            viewModel.mapRegion = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: landmark.latitude, longitude: landmark.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
        }

        // 打开系统地图应用进行路线规划
        func openMapsForNavigation() {
            let destinationPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: landmark.latitude, longitude: landmark.longitude))
            let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
            destinationMapItem.name = landmark.name

            // 打开系统地图应用，并提供从当前位置到目的地的路线规划
            destinationMapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        }

        // 获取相似景点
        func similarLandmarks() -> [Landmark] {
            return viewModel.landmarks.filter { similarLandmarkIds.contains($0.id) && $0.id != landmark.id }
        }
    }
