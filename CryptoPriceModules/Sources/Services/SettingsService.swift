//
//  SettingsServiec.swift
//  CryptoPriceModules
//
//  Created by Markus Mattfolk Stenberg on 2024-09-22.
//

import Foundation
import Models
import Combine

public protocol SettingsServicing: Sendable {
    func getPreferredCurrency() -> String
    func setPreferredCurrency(_ currency: Currency)
    
    func selectedCurrencyPublisher() -> AnyPublisher<String, Never>
}

final public class SettingsService: SettingsServicing {
    public init() {
    }
    
    public func getPreferredCurrency() -> String {
        guard let selectedCurrency = UserDefaults.standard.string(forKey: "selectedCurrency") else {
            return Currency.usd.rawValue
        }
        return selectedCurrency
    }
    
    public func setPreferredCurrency(_ currency: Currency) {
        UserDefaults.standard.set(currency.rawValue, forKey: "selectedCurrency")
    }
    
    public func selectedCurrencyPublisher() -> AnyPublisher<String, Never> {
            return UserDefaults.standard
                .publisher(for: \.selectedCurrency)
                .eraseToAnyPublisher()
        }
}

extension UserDefaults {
    @objc dynamic var selectedCurrency: String {
        get {
            return string(forKey: "selectedCurrency") ?? Currency.usd.rawValue
        }
        set {
            set(newValue, forKey: "selectedCurrency")
        }
    }
}
