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

    // 随机生成相似景点的数量
    private let similarLandmarkCount = 3

    // 默认的加州伯克利大学的经纬度
    private let defaultLocation = CLLocation(latitude: 37.8719, longitude: -122.2585)

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

                // 导航按钮、距离、收藏按钮和分享按钮在一排显示
                HStack {
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

                    Spacer() // 将导航按钮和距离文本分开

                    if let distance = distance {
                        Text("距离: \(String(format: "%.2f", distance / 1000)) km")
                            .font(.headline)
                            .padding(.top)
                    } else {
                        Text("正在计算距离...")
                            .font(.headline)
                            .padding(.top)
                    }

                    Spacer() // 将距离文本和收藏按钮分开

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

                    Spacer() // 将收藏按钮和分享按钮分开

                    Button(action: {
                        shareLandmark()
                    }) {
                        Text("分享")
                            .font(.headline)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
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
        let userLocation = locationManager.userLocation ?? defaultLocation // 如果无法获取用户位置，使用默认位置
        let landmarkLocation = CLLocation(latitude: landmark.latitude, longitude: landmark.longitude)
        distance = userLocation.distance(from: landmarkLocation) // 计算距离
    }

    // 更新地图中心点为当前景点的经纬度
    func updateMapCenter() {
        viewModel.mapRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: landmark.latitude, longitude: landmark.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
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
        // 生成随机的相似景点 ID
        let allLandmarkIds = viewModel.landmarks.map { $0.id }
        var randomIds = Set<Int>()

        while randomIds.count < similarLandmarkCount {
            if let randomId = allLandmarkIds.randomElement() {
                if randomId != landmark.id { // 确保不推荐当前景点
                    randomIds.insert(randomId)
                }
            }
        }

        return viewModel.landmarks.filter { randomIds.contains($0.id) }
    }

    // 分享地标信息
    func shareLandmark() {
        let activityItems: [Any] = [
            "来看看这个地标：\(landmark.name)",
            UIImage(named: landmark.image) ?? UIImage(),
            "经纬度：\(landmark.latitude), \(landmark.longitude)"
        ]

        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)

        // 获取当前的 UIViewController
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityViewController, animated: true, completion: nil)
        }
    }
}
