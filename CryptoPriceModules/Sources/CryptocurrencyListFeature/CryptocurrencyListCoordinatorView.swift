//
//  CryptocurrencyListCoordinatorView.swift
//  CryptoPriceModules
//
//  Created by Markus Mattfolk Stenberg on 2024-09-22.
//

import Foundation
import SwiftUI
import Common
import CryptocurrencyDetailsFeature
import Services

public struct CryptocurrencyListCoordinatorView: View {
    @ObservedObject var viewModel: ViewModel

    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        NavigationStack(path: $viewModel.pageStack) {
            view(for: viewModel.activeRootPage)
                .navigationDestination(for: StackPage.self) { page in
                    view(for: page)
                }
        }
    }
    
    @ViewBuilder
    private func view(for page: StackPage) -> some View {
        switch page {
        case  .list(let viewModel):
            CryptocurrencyListView(viewModel: viewModel)
        case .details(let viewModel):
            CryptocurrencyDetailsView(viewModel: viewModel)
        }
    }
}

extension CryptocurrencyListCoordinatorView {
    enum StackPage: Hashable, Identifiable {
        case list(CryptocurrencyListView.ViewModel)
        case details(CryptocurrencyDetailsView.ViewModel)
    }
}

extension CryptocurrencyListCoordinatorView {
    @MainActor
    public final class ViewModel: ObservableObject, Hashable, Identifiable {
        public enum Output: Sendable {
            case didTapSettings
        }
        
        public var onOutPut: ((Output) -> Void)?
        
        @Published var activeRootPage: StackPage
        @Published var pageStack: [StackPage] = []
        
        public let cryptoCurrencyListViewmodel: CryptocurrencyListView.ViewModel
        
        private let cryptocurrencyService: CryptocurrencyServicing
        private let exchangeRateService: ExchangeRateServicing
        private let settingsService: SettingsServicing
        
        public init (cryptocurrencyService: CryptocurrencyServicing,
                     exchangeRateService: ExchangeRateServicing,
                     settingsService: SettingsServicing,
                     onOutPut: ((Output) -> Void)? = nil) {
            self.onOutPut = onOutPut
            self.cryptocurrencyService = cryptocurrencyService
            self.exchangeRateService = exchangeRateService
            self.settingsService = settingsService
            cryptoCurrencyListViewmodel = CryptocurrencyListView.ViewModel(cryptocurrencyService: self.cryptocurrencyService, exchangeRateService: self.exchangeRateService, settingsService: self.settingsService)
            activeRootPage = .list(cryptoCurrencyListViewmodel)
            
            bind(to: cryptoCurrencyListViewmodel)
        }
        
        
        private func bind(to viewModel: CryptocurrencyListView.ViewModel) {
            viewModel.onOutPut = { [weak self] output in
                switch output {
                case .didTapSettings:
                    self?.onOutPut?(.didTapSettings)
                case .didSelect(let cryptocurrency):
                    self?.pageStack.append(StackPage.details(.init(cryptocurrency: cryptocurrency)))
                }
            }
        }
    }
}
