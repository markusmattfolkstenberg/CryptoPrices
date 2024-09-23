//
//  CryptocurrencyListView.swift
//  CryptoPrice
//
//  Created by Markus Mattfolk Stenberg on 2024-09-22.
//

import SwiftUI
import Common
import Models
import Services
import Combine

public struct CryptocurrencyListView: View {
    @ObservedObject public var viewModel: CryptocurrencyListView.ViewModel

    public init(viewModel: CryptocurrencyListView.ViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            List {
                switch viewModel.viewState {
                case .loading:
                    ProgressView("Loading...")
                        .id(UUID())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                case .success(let cryptocurrencies):
                    ForEach(cryptocurrencies) { crypto in
                        cryptoRow(crypto: crypto)
                            .onTapGesture {
                                viewModel.didSelect(crypto)
                            }
                    }
                    
                case .error(let error):
                    ErrorView(message: error.localizedDescription) {
                            viewModel.onErrorRetry()
                    }
                }
            }
            .refreshable {
                viewModel.onPullToRefresh()
            }
        }
        .navigationTitle("Cryptocurrencies")
        .toolbar {
            Button(action: {
                viewModel.didTapSettings()
            }) {
                Image(systemName: "gear")
            }
        }
    }
    
        @ViewBuilder
        private func cryptoRow(crypto: CryptocurrencyDisplayData) -> some View {
            HStack {
                VStack(alignment: .leading) {
                    Text(crypto.name)
                        .font(.headline)
                    Text(crypto.symbol)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text(crypto.lastPrice)
                        .font(.headline)
                    Text(crypto.priceChange)
                        .foregroundColor(crypto.priceChange.contains("-") ? .red : .green)
                }
            }
            .padding(.vertical, 8)
        }
}

extension CryptocurrencyListView {
    @MainActor
    public final class ViewModel: ObservableObject, Hashable, Identifiable {
        public enum Output {
            case didSelect(CryptocurrencyDisplayData)
            case didTapSettings
        }
        
        public var onOutPut: ((Output) -> Void)?
        @Published public var viewState: ViewState<[CryptocurrencyDisplayData]> = .loading
        
        private let cryptocurrencyService: CryptocurrencyServicing
        private let exchangeRateService: ExchangeRateServicing
        private let settingsService: SettingsServicing
        private var cancellables = Set<AnyCancellable>()
        
        public init(
            cryptocurrencyService: CryptocurrencyServicing,
            exchangeRateService: ExchangeRateServicing,
            settingsService: SettingsServicing,
            onOutPut: ((Output) -> Void)? = nil
        ) {
            self.cryptocurrencyService = cryptocurrencyService
            self.exchangeRateService = exchangeRateService
            self.settingsService = settingsService
            self.onOutPut = onOutPut
            
            settingsService.selectedCurrencyPublisher()
                .dropFirst()
                .sink { [weak self] newCurrency in
                    guard let self = self else { return }
                    self.onPreferedCurrencyChange()
                    }.store(in: &cancellables)
            
            Task {
                await loadCryptocurrencies()
            }
        }
        
        public func loadCryptocurrencies() async {
            Task.detached {[weak self, exchangeRateService, cryptocurrencyService] in
                guard let self else { return }
                await MainActor.run {
                    self.viewState = .loading
                }
            
                do {
                    let cryptos = try await cryptocurrencyService.fetchCryptocurrencies()
                    let preferredCurrency = self.settingsService.getPreferredCurrency()

                    let exchangeRate = try await exchangeRateService.fetchExchangeRate(for: preferredCurrency)

                    // Map each cryptocurrency to CryptocurrencyDisplayData using the currency symbol
                    let displayModels = cryptos.map { crypto in
                        CryptocurrencyDisplayData(from: crypto, exchangeRate: exchangeRate, currencyCode: preferredCurrency)
                    }

                    await MainActor.run {
                        self.viewState = .success(displayModels)
                    }
                } catch {
                    await MainActor.run {
                        self.viewState = .error(error)
                    }
                }
            }
        }
        
        public func onErrorRetry() {
            Task {
                await loadCryptocurrencies()
            }
        }
        
        public func onPreferedCurrencyChange() {
            Task {
                await loadCryptocurrencies()
            }
        }
        
        public func onPullToRefresh() {
            Task {
                await loadCryptocurrencies()
            }
        }
        
        public func didSelect(_ cryptocurrency: CryptocurrencyDisplayData) {
            onOutPut?(.didSelect(cryptocurrency))
        }
        
        public func didTapSettings() {
            onOutPut?(.didTapSettings)
        }
    }
}
