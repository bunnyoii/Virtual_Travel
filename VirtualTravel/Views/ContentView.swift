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
                MapView(viewModel: viewModel)
                    .frame(height: 300)
                    .padding(.bottom)

                List(viewModel.landmarks) { landmark in
                    NavigationLink(destination: LandmarkDetailView(landmark: landmark)) {
                        Text(landmark.name)
                    }
                }
                .navigationTitle("Landmarks")
            }
        }
    }
}
