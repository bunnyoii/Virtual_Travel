//
//  LandmarkDetailView.swift
//  VirtualTravel
//
//  SwiftUI 视图文件，用于显示单个地标的详细信息
//
//  更新于 2024/12/21
//

import SwiftUI
import MapKit

struct LandmarkDetailView: View {
    let landmark: Landmark // 当前地标
    @StateObject var locationManager = LocationManager() // 位置管理器
    @State private var distance: Double? // 用户位置到地标的距离
    @ObservedObject var viewModel: LandmarkViewModel // 视图模型，管理地标数据
    @EnvironmentObject var appSettings: AppSettings // 应用设置，管理颜色模式
    @AppStorage("favoriteLandmarksData") private var favoriteLandmarksData: Data? // 存储收藏的地标数据
    @State private var favoriteLandmarks: [Int] = [] // 收藏的地标 ID 列表
    @State private var nearbyRestaurants: [Place] = [] // 附近的餐厅
    @State private var nearbyHotels: [Place] = [] // 附近的旅馆
    
    @Environment(\.presentationMode) var presentationMode // 用于管理导航状态
    
    private let similarLandmarkCount = 5 // 相似景点推荐的数量
    private let defaultLocation = CLLocation(latitude: 37.8719, longitude: -122.2585) // 默认位置：加州伯克利大学
    private let geoapifyService = GeoapifyService() // Geoapify 服务，用于获取附近的地点
    
    @State private var localMapRegion: MKCoordinateRegion
    
    init(landmark: Landmark, viewModel: LandmarkViewModel) {
        self.landmark = landmark
        self.viewModel = viewModel
        self._localMapRegion = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: landmark.latitude, longitude: landmark.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
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
                
                // 查看附近地图按钮
                Button(action: {
                    // 更新主页的地图区域
                    viewModel.mapRegion = MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: landmark.latitude, longitude: landmark.longitude),
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                    // 触发导航回到主界面
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("查看附近地图")
                        .font(.headline)
                        .padding()
                        .background(Color(UIColor.systemGray5))
                        .foregroundColor(Color(UIColor.label))
                        .cornerRadius(8)
                }
                .padding(.top)
                
                // 导航按钮、距离、收藏按钮和分享按钮在一排显示
                HStack {
                    Button(action: {
                        openMapsForNavigation()
                    }) {
                        Image(systemName: "arrow.triangle.turn.up.right.diamond.fill") // 导航图标
                            .font(.title)
                            .frame(width: 45, height: 45)
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
                        Image(systemName: favoriteLandmarks.contains(landmark.id) ? "heart.fill" : "heart")// 收藏图标
                            .font(.title)
                            .frame(width: 45, height: 45)
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
                            .frame(width: 45, height: 45)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    // 显示当前距离该景点的距离
                    if let distance = distance {
                        Text("\(String(format: "%.2f", distance / 1000)) km")
                            .font(.headline)
                            .padding(.top)
                    } else {
                        Text("正在计算距离...")
                            .font(.headline)
                            .padding(.top)
                    }
                }
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
                                                .overlay(Circle().stroke(Color(UIColor.label), lineWidth: 2))
                                        } else {
                                            Text("图片加载失败")
                                                .foregroundColor(Color(UIColor.label))
                                                .frame(width: 80, height: 80)
                                        }
                                        Text(similarLandmark.name)
                                            .font(.caption)
                                            .foregroundColor(Color(UIColor.label))
                                    }
                                    .padding()
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                .padding(.top)
                
                // 附近餐厅推荐
                VStack(alignment: .leading, spacing: 16) {
                    Text("附近餐厅推荐")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    if nearbyRestaurants.isEmpty {
                        Text("抱歉，附近暂无餐厅") // 显示提示信息
                            .font(.subheadline)
                            .foregroundColor(Color(UIColor.secondaryLabel)) // 使用系统次要文字颜色
                            .padding(.top, 8)
                    } else {
                        ForEach(nearbyRestaurants) { restaurant in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(restaurant.name)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(UIColor.label)) // 使用系统文字颜色
                                
                                Text(restaurant.address)
                                    .font(.body)
                                    .foregroundColor(Color(UIColor.secondaryLabel)) // 使用系统次要文字颜色
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(.top)

                // 附近旅馆推荐
                VStack(alignment: .leading, spacing: 16) {
                    Text("附近旅馆推荐")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    if nearbyHotels.isEmpty {
                        Text("抱歉，附近暂无旅馆") // 显示提示信息
                            .font(.subheadline)
                            .foregroundColor(Color(UIColor.secondaryLabel)) // 使用系统次要文字颜色
                            .padding(.top, 8)
                    } else {
                        ForEach(nearbyHotels) { hotel in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(hotel.name)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(UIColor.label)) // 使用系统文字颜色
                                
                                Text(hotel.address)
                                    .font(.body)
                                    .foregroundColor(Color(UIColor.secondaryLabel)) // 使用系统次要文字颜色
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .cornerRadius(8)
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
            // 更新本地地图区域
            localMapRegion = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: landmark.latitude, longitude: landmark.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
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
    
    // 获取相似景点（相同类别，最多5个）
    func similarLandmarks() -> [Landmark] {
        // 过滤出相同类别的景点
        let sameCategoryLandmarks = viewModel.landmarks.filter {
            $0.category == landmark.category && $0.id != landmark.id
        }
        
        // 如果相同类别的景点不足5个，返回所有符合条件的景点
        if sameCategoryLandmarks.count <= 5 {
            return sameCategoryLandmarks
        }
        
        // 如果超过5个，随机选择5个
        return Array(sameCategoryLandmarks.shuffled().prefix(5))
    }
    
    // 分享地标信息
    func shareLandmark() {
        let activityItems: [Any] = [
            "来看看这个景点：\(landmark.name)",
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
