//
//  WelcomeView.swift
//  VirtualTravel
//
//  SwiftUI 视图文件，用于显示欢迎界面
//
//  更新于 2024/12/22
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var appSettings: AppSettings // 获取 AppSettings
    @State private var isShowingContentView = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Logo 和标题
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                
                Text("Virtual Travel")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                // 欢迎语
                Text("欢迎使用Virtual Travel！\n探索世界各地的景点，获取详细的导览信息。")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                
                // 开始按钮
                NavigationLink(destination: ContentView().navigationBarBackButtonHidden(true), isActive: $isShowingContentView) {
                    Button(action: {
                        isShowingContentView = true // 点击按钮后切换到主界面
                    }) {
                        Text("开始探索")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
            .navigationBarHidden(true)  // 隐藏导航栏
            .preferredColorScheme(appSettings.colorScheme) // 设置颜色模式
        }
    }
}
