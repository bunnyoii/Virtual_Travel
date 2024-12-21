//
//  AppSettings.swift
//  VirtualTravel
//
//  `AppSettings` 类管理应用程序的设置，特别是颜色方案（浅色或深色模式）。
//
//  更新于 2024/12/21
//

import SwiftUI

class AppSettings: ObservableObject {
    @AppStorage("colorScheme") private var colorSchemeString: String = "light"

    // 一个计算属性，根据 `colorSchemeString` 确定当前的颜色方案。
    var colorScheme: ColorScheme {
        get {
            colorSchemeString == "dark" ? .dark : .light
        }
        set {
            colorSchemeString = newValue == .dark ? "dark" : "light"
        }
    }
}