//
//  LandmarkInfoBox.swift
//  VirtualTravel
//
//  Created by 刘淑仪 on 2024/12/19.
//

import SwiftUI

struct LandmarkInfoBox: View {
    let landmark: Landmark

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(landmark.name)
                .font(.headline)
            Text(landmark.description)
                .font(.subheadline)
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 4)
    }
}
