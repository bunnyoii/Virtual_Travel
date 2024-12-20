//
//  FavoritesView.swift
//  VirtualTravel
//
//  Created by 刘淑仪 on 2024/12/20.
//

import SwiftUI

struct FavoritesView: View {
    @AppStorage("favoriteLandmarksData") private var favoriteLandmarksData: Data? // 存储为 Data 类型
    @ObservedObject var viewModel: LandmarkViewModel
    @State private var favoriteLandmarks: [Int] = [] // 使用 @State 存储可变的收藏列表

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.landmarks.filter { favoriteLandmarks.contains($0.id) }) { landmark in
                    NavigationLink(destination: LandmarkDetailView(landmark: landmark, viewModel: viewModel)) {
                        HStack {
                            if let image = UIImage(named: landmark.image) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            }
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
