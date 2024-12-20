//
//  MapView.swift
//  VirtualTravel
//
//  SwiftUI 视图文件，用于在地图上显示地标的位置
//
//  Updated by 刘淑仪 on 2024/12/20
//

import SwiftUI
import MapKit

struct MapView: View {
    @ObservedObject var viewModel: LandmarkViewModel

    var body: some View {
        Map(
            coordinateRegion: $viewModel.mapRegion,
            interactionModes: .all,
            showsUserLocation: true,
            annotationItems: viewModel.filteredLandmarks, // 使用过滤后的地标
            annotationContent: { landmark in
                MapAnnotation(coordinate: landmark.coordinate) {
                    NavigationLink(destination: LandmarkDetailView(landmark: landmark, viewModel: viewModel)) {
                        VStack {
                            Text(landmark.name)
                                .font(.caption)
                                .padding(4)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(4)
                                .shadow(radius: 2)
                            if let image = UIImage(named: landmark.image) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                    .shadow(radius: 3)
                            }
                        }
                    }
                }
            }
        )
    }
}
