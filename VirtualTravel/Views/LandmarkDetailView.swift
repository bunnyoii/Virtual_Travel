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
    @ObservedObject var viewModel: LandmarkViewModel
    @EnvironmentObject var appSettings: AppSettings
    @AppStorage("favoriteLandmarksData") private var favoriteLandmarksData: Data?
    @State private var favoriteLandmarks: [Int] = []
    @State private var nearbyRestaurants: [Place] = [] // 附近的餐厅
    @State private var nearbyHotels: [Place] = [] // 附近的旅馆

    private let similarLandmarkCount = 3
    private let defaultLocation = CLLocation(latitude: 37.8719, longitude: -122.2585)
    private let geoapifyService = GeoapifyService() // 初始化 GeoapifyService

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
                        Image(systemName: "arrow.triangle.turn.up.right.diamond.fill") // 导航图标
                            .font(.title)
                            .frame(width: 45, height: 45) // 统一设置图标大小
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }

                    Spacer()

                    Button(action: {
                        if favoriteLandmarks.contains(landmark.id) {
                            favoriteLandmarks.removeAll { $0 == landmark.id }
                        } else {
                            favoriteLandmarks.append(landmark.id)
                        }
                        saveFavoriteLandmarks()
                    }) {
                        Image(systemName: favoriteLandmarks.contains(landmark.id) ? "heart.fill" : "heart")
                            .font(.title)
                            .frame(width: 45, height: 45) // 统一设置图标大小
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }

                    Spacer()

                    Button(action: {
                        shareLandmark()
                    }) {
                        Image(systemName: "square.and.arrow.up") // 分享图标
                            .font(.title)
                            .frame(width: 45, height: 45) // 统一设置图标大小
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Spacer()

                    if let distance = distance {
                        Text("\(String(format: "%.2f", distance / 1000)) km")
                            .font(.headline)
                            .padding(.top)
                    } else {
                        Text("正在计算距离...")
                            .font(.headline)
                            .padding(.top)
                    }                }
                .padding(.top)

                // 相似景点推荐
                VStack(alignment: .leading, spacing: 8) {
                    Text("相似景点推荐")
                        .font(.headline)
                        .fontWeight(.bold)
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

                // 附近餐厅推荐
                VStack(alignment: .leading, spacing: 16) {
                    Text("附近餐厅推荐")
                        .font(.headline) // 大一号字并加粗
                        .fontWeight(.bold)
                        .padding(.top)

                    if nearbyRestaurants.isEmpty {
                        Text("抱歉，附近暂无餐厅") // 显示提示信息
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                    } else {
                        ForEach(nearbyRestaurants) { restaurant in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(restaurant.name)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)

                                Text(restaurant.address)
                                    .font(.body)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                .padding(.top)

                // 附近旅馆推荐
                VStack(alignment: .leading, spacing: 16) {
                    Text("附近旅馆推荐")
                        .font(.headline) // 大一号字并加粗
                        .fontWeight(.bold)
                        .padding(.top)

                    if nearbyHotels.isEmpty {
                        Text("抱歉，附近暂无旅馆") // 显示提示信息
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                    } else {
                        ForEach(nearbyHotels) { hotel in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(hotel.name)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)

                                Text(hotel.address)
                                    .font(.body)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                .padding(.top)
            }
            .padding()
        }
        .navigationTitle(landmark.name)
        .onAppear {
            loadFavoriteLandmarks()
            calculateDistance()
            fetchNearbyPlaces()
            updateMapCenter() // 确保地图中心点更新为当前景点的经纬度
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
        let userLocation = locationManager.userLocation ?? defaultLocation
        let landmarkLocation = CLLocation(latitude: landmark.latitude, longitude: landmark.longitude)
        distance = userLocation.distance(from: landmarkLocation)
    }

    // 获取附近的餐厅和旅馆
    func fetchNearbyPlaces() {
        let latitude = landmark.latitude
        let longitude = landmark.longitude
        let radius = 1500.0 // 搜索半径（米）

        print("Fetching places for latitude: \(latitude), longitude: \(longitude)") // 打印经纬度

        // 获取附近的餐厅
        geoapifyService.fetchNearbyPlaces(latitude: latitude, longitude: longitude, radius: radius, type: "catering.restaurant") { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let restaurants):
                    if restaurants.isEmpty {
                        print("No restaurants found nearby")
                    } else {
                        self.nearbyRestaurants = restaurants
                    }
                case .failure(let error):
                    print("Error fetching nearby restaurants: \(error)")
                }
            }
        }

        // 获取附近的旅馆
        geoapifyService.fetchNearbyPlaces(latitude: latitude, longitude: longitude, radius: radius, type: "accommodation.hotel") { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let hotels):
                    if hotels.isEmpty {
                        print("No hotels found nearby")
                    } else {
                        self.nearbyHotels = hotels
                    }
                case .failure(let error):
                    print("Error fetching nearby hotels: \(error)")
                }
            }
        }
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

        destinationMapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }

    // 获取相似景点
    func similarLandmarks() -> [Landmark] {
        let allLandmarkIds = viewModel.landmarks.map { $0.id }
        var randomIds = Set<Int>()

        while randomIds.count < similarLandmarkCount {
            if let randomId = allLandmarkIds.randomElement() {
                if randomId != landmark.id {
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

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityViewController, animated: true, completion: nil)
        }
    }
}
