//
//  AppSettings.swift
//  VirtualTravel
//
//  Created by 刘淑仪 on 2024/12/21.
//

import SwiftUI

class AppSettings: ObservableObject {
    @AppStorage("colorScheme") private var colorSchemeString: String = "light" // 默认是浅色模式

    var colorScheme: ColorScheme {
        get {
            colorSchemeString == "dark" ? .dark : .light
        }
        set {
            colorSchemeString = newValue == .dark ? "dark" : "light"
        }
    }
}
