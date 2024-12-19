//
//  ContentView.swift
//  VirtualTravel
//
//  Created by 刘淑仪 on 2024/12/19.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = LandmarkViewModel()
    @State private var searchText = ""

    var filteredLandmarks: [Landmark] {
        if searchText.isEmpty {
            return viewModel.landmarks
        } else {
            return viewModel.landmarks.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                // 搜索框
                TextField("Search landmarks", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                // 地图视图
                MapView()
                    .frame(height: 300) // 设置地图的高度
                    .padding(.bottom)

                // 地标列表
                List(filteredLandmarks) { landmark in
                    NavigationLink(destination: LandmarkDetailView(landmark: landmark)) {
                        Text(landmark.name)
                    }
                }
                .navigationTitle("Landmarks")
            }
        }
    }
}
