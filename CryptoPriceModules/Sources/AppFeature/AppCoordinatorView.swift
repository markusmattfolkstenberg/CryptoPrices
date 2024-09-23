//
//  AppCoordinatorView.swift
//  CryptoPrice
//
//  Created by Markus Mattfolk Stenberg on 2024-09-22.
//

import SwiftUI
import CryptocurrencyListFeature
import Models
import CryptocurrencyDetailsFeature
import SettingsFeature
import Common

public struct AppCoordinatorView: View {
    @ObservedObject var viewModel: ViewModel
    
    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        CryptocurrencyListCoordinatorView(viewModel: viewModel.cryptocurrencyListCoordinatorViewModel)
            .sheet(item: $viewModel.presentedSheet, content: { sheet in
                view(for: sheet)
            })
    }
    
    @ViewBuilder
        private func view(for sheet: SheetPage) -> some View {
            switch sheet {
                case .settings(let viewModel):
                SettingsView(viewModel: viewModel)
            }
        }
}

extension AppCoordinatorView {
    enum SheetPage: Hashable, Identifiable {
        case settings(SettingsView.ViewModel)
    }
}

public extension AppCoordinatorView {
    @MainActor
    final class ViewModel: ObservableObject, Hashable, Identifiable {
        @Published var presentedSheet: SheetPage? = nil

        public let cryptocurrencyListCoordinatorViewModel: CryptocurrencyListCoordinatorView.ViewModel
        
        private let dependencyContainer = DependencyContainer()
        
        public init() {
            cryptocurrencyListCoordinatorViewModel = .init(cryptocurrencyService: dependencyContainer.cryptocurrencyService, exchangeRateService: dependencyContainer.exchangeRateService, settingsService: dependencyContainer.settingsService)
            bind(to: cryptocurrencyListCoordinatorViewModel)
        }
        
        private func present(_ sheet: SheetPage) {
            self.presentedSheet = sheet
        }
        
        private func dismissSheet() {
            presentedSheet = nil
        }
        
        private func bind(to viewModel: CryptocurrencyListCoordinatorView.ViewModel) {
            viewModel.onOutPut = { [weak self] output in
                guard let self else { return }
                switch output {
                case .didTapSettings:
                    self.present(.settings(.init(settingsService: self.dependencyContainer.settingsService, onOutput: { output in
                        switch output {
                        case .cancelTapped, .saveTapped:
                            self.dismissSheet()
                        }
                    })))
                }
            }
        }
    }
}
