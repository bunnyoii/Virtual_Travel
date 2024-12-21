//
//  VirtualTravelApp.swift
//  VirtualTravel
//  
//  VirtualTravel 应用程序的主入口，初始化应用程序并启动主视图
//
//  更新于 2024/12/21
//

import SwiftUI

@main
struct VirtualTravelApp: App {
    @StateObject private var appSettings = AppSettings()
    
    var body: some Scene {
        WindowGroup {
            WelcomeView()
                .environmentObject(appSettings) // 将 AppSettings 注入环境
        }
    }
}
