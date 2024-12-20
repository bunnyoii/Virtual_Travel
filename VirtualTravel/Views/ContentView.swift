//
//  ContentView.swift
//  VirtualTravel
//
//  SwiftUI 视图文件，用于定义应用程序的主界面
//
//  Updated by 刘淑仪 on 2024/12/20
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = LandmarkViewModel()

    var body: some View {
        NavigationView {
            VStack {
                // 搜索框
                SearchBar(text: $viewModel.searchText)
                    .padding(.horizontal)

                // 地图视图
                MapView(viewModel: viewModel)
                    .frame(height: 300)
                    .padding(.bottom)

                List(viewModel.filteredLandmarks) { landmark in
                    NavigationLink(destination: LandmarkDetailView(landmark: landmark, viewModel: viewModel)) {
                        Text(landmark.name)
                    }
                }
                .navigationTitle("Landmarks")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: FavoritesView(viewModel: viewModel)) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
}

// 自定义搜索框
struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField("Search...", text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)

                        if !text.isEmpty {
                            Button(action: {
                                self.text = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .padding(.horizontal, 10)
        }
    }
}
