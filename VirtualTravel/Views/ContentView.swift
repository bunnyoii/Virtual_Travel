//
//  ContentView.swift
//  VirtualTravel
//
//  Created by 刘淑仪 on 2024/12/19.
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
