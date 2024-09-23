//
//  DependencyContainer.swift
//  CryptoPrice
//
//  Created by Markus Mattfolk Stenberg on 2024-09-22.
//

import Foundation
import Services

public final class DependencyContainer {
    let cryptocurrencyService: CryptocurrencyServicing
    let exchangeRateService: ExchangeRateServicing
    let settingsService: SettingsServicing

    public init() {
        self.cryptocurrencyService = CryptocurrencyService()
        self.exchangeRateService = ExchangeRateService()
        self.settingsService = SettingsService()
    }
}
