//
//  LandmarkInfoBox.swift
//  VirtualTravel
//
//  SwiftUI 视图文件，用于显示地标的简要信息
//
//  更新于 2024/12/21
//

import SwiftUI

struct LandmarkInfoBox: View {
    let landmark: Landmark // 地标数据
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(landmark.name) // 地标名称
                .font(.headline)
            Text(landmark.description) // 地标描述
                .font(.subheadline)
        }
        .padding(8) // 内边距
        .background(Color.white) // 背景颜色
        .cornerRadius(8) // 圆角
        .shadow(radius: 4) // 阴影效果
    }
}