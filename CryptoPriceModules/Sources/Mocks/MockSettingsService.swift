//
//  MockSettingsService.swift
//  CryptoPriceModules
//
//  Created by Markus Mattfolk Stenberg on 2024-09-22.
//

import Services
import Models
import Combine

public final class MockSettingsService: SettingsServicing, @unchecked Sendable  {
    private var preferredCurrency: String = "USD"
    private var currencySubject = PassthroughSubject<String, Never>()
    
    public init(){}
    
    public func selectedCurrencyPublisher() -> AnyPublisher<String, Never> {
        return currencySubject.eraseToAnyPublisher()
    }
    
    public func getPreferredCurrency() -> String {
        return preferredCurrency
    }
    
    public func setPreferredCurrency(_ currency: Models.Currency) {
        preferredCurrency = currency.rawValue
        currencySubject.send(currency.rawValue)
    }
}
