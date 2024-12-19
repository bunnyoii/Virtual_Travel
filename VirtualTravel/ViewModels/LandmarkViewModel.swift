//
//  LandmarkViewModel.swift
//  VirtualTravel
//
//  Created by 刘淑仪 on 2024/12/19.
//

import Foundation

class LandmarkViewModel: ObservableObject {
    @Published var landmarks: [Landmark] = []

    init() {
        loadLandmarks()
    }

    func loadLandmarks() {
        if let url = Bundle.main.url(forResource: "landmarks", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                landmarks = try JSONDecoder().decode([Landmark].self, from: data)
            } catch {
                print("Error loading landmarks: \(error)")
            }
        }
    }
}
