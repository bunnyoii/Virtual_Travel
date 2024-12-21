//
//  VirtualTravelApp.swift
//  VirtualTravel
//  
//  VirtualTravel 应用程序的主入口，初始化应用程序并启动主视图
//
//  Updated by 刘淑仪 on 2024/12/20
//

import SwiftUI

@main
struct VirtualTravelApp: App {
    @StateObject private var appSettings = AppSettings() // 初始化 AppSettings

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appSettings) // 将 AppSettings 注入到环境中
                .preferredColorScheme(appSettings.colorScheme) // 设置应用的颜色模式
        }
    }
}
