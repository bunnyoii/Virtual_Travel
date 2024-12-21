//
//  ContentView.swift
//  VirtualTravel
//
//  SwiftUI 视图文件，用于定义应用程序的主界面
//
//  更新于 2024/12/20
//

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject var viewModel = LandmarkViewModel() // 视图模型，管理地标数据和地图状态
    @EnvironmentObject var appSettings: AppSettings // 获取 AppSettings，用于管理颜色模式
    @State private var selectedCategory: String? = nil // 当前选中的类别
    @State private var lastViewedLandmark: Landmark? = nil // 存储用户最后一次查看的地标
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) { // 去掉 VStack 的默认间距
                // 搜索框
                SearchBar(text: $viewModel.searchText)
                    .padding(.horizontal, 8) // 水平填充
                    .padding(.vertical, 8) // 垂直填充
                
                // 地图视图
                MapView(viewModel: viewModel)
                    .frame(height: 300)
                    .padding(.bottom, 8) // 添加少量底部填充
                
                // 类别选择器
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.categories, id: \.self) { category in
                            Button(action: {
                                selectedCategory = category
                            }) {
                                Text(category)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(selectedCategory == category ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(selectedCategory == category ? .white : .primary) // 使用 .primary 动态颜色
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                }
                .background(Color(UIColor.systemBackground)) // 使用系统背景颜色
                .padding(.vertical, 8)
                
                // 根据选择的类别过滤景点
                List(viewModel.filteredLandmarks.filter { selectedCategory == nil || $0.category == selectedCategory }) { landmark in
                    NavigationLink(destination: LandmarkDetailView(landmark: landmark, viewModel: viewModel)) {
                        Text(landmark.name)
                    }
                }
                .listStyle(PlainListStyle()) // 使用 PlainListStyle 去掉列表的默认样式
            }
            
            // 工具栏：显示收藏夹按钮还有亮暗模式切换按钮
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: FavoritesView(viewModel: viewModel)) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        toggleColorScheme()
                    }) {
                        Image(systemName: appSettings.colorScheme == .dark ? "sun.max.fill" : "moon.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
            // 标题
            .navigationTitle("Virtual Travel")
        }
    }
    
    // 切换颜色模式
    private func toggleColorScheme() {
        appSettings.colorScheme = (appSettings.colorScheme == .dark) ? .light : .dark
    }
}

// 自定义搜索框
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("搜索...", text: $text)
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
