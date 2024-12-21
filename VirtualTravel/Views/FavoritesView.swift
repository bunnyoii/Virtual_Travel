//
//  FavoritesView.swift
//  VirtualTravel
//
//  收藏夹视图，用于显示用户收藏的地标列表。
//  每个收藏项包含地标的图片和名称，点击后跳转到地标的详细视图
//
//  更新于 2024/12/21
//

import SwiftUI

struct FavoritesView: View {
    @AppStorage("favoriteLandmarksData") private var favoriteLandmarksData: Data? // 存储为 Data 类型
    @ObservedObject var viewModel: LandmarkViewModel // 视图模型，管理地标数据
    @State private var favoriteLandmarks: [Int] = [] // 使用 @State 存储可变的收藏列表
    
    var body: some View {
        NavigationView {
            List {
                // 遍历收藏的地标并显示
                ForEach(viewModel.landmarks.filter { favoriteLandmarks.contains($0.id) }) { landmark in
                    NavigationLink(destination: LandmarkDetailView(landmark: landmark, viewModel: viewModel)) {
                        HStack {
                            // 显示地标的图片
                            if let image = UIImage(named: landmark.image) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            }
                            // 显示地标的名称
                            Text(landmark.name)
                        }
                    }
                }
            }
            .navigationTitle("收藏夹")
            .onAppear {
                loadFavoriteLandmarks() // 加载收藏列表
            }
        }
    }
    
    // 加载收藏列表
    func loadFavoriteLandmarks() {
        if let data = favoriteLandmarksData,
           let ids = try? JSONDecoder().decode([Int].self, from: data) {
            favoriteLandmarks = ids
        } else {
            favoriteLandmarks = []
        }
    }
}