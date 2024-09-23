//
//  CryptoPriceApp.swift
//  CryptoPrice
//
//  Created by Markus Mattfolk Stenberg on 2024-09-22.
//

import SwiftUI
import AppFeature

@main
struct CryptoPriceApp: App {
    @StateObject private var appCoordinatorViewModel = AppCoordinatorView.ViewModel()

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView(viewModel: appCoordinatorViewModel)
        }
    }
}


