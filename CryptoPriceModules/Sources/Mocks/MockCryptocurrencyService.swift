//
//  MockCryptocurrencyService.swift
//  CryptoPriceModules
//
//  Created by Markus Mattfolk Stenberg on 2024-09-22.
//
import Foundation
import Services
import Models

final public actor MockCryptocurrencyService: CryptocurrencyServicing {
    private var _mockCryptocurrencies: [Cryptocurrency] = []
    private var _shouldThrowError: Bool = false // Private backing variable
    
    public init() {}

    public func setMockCryptocurrencies(_ cryptocurrencies: [Cryptocurrency]) {
        _mockCryptocurrencies = cryptocurrencies
    }

    public func setShouldThrowError(_ shouldThrow: Bool) {
        _shouldThrowError = shouldThrow
    }

    public func fetchCryptocurrencies() async throws -> [Cryptocurrency] {
        if _shouldThrowError {
            throw NetworkError.invalidResponse // Simulate error
        }
        
        return _mockCryptocurrencies.isEmpty ? [
            Cryptocurrency(
                symbol: "btcinr",
                baseAsset: "btc",
                quoteAsset: "inr",
                openPrice: 5000000.0,
                lowPrice: 4800000.0,
                highPrice: 5100000.0,
                lastPrice: 5050000.0,
                volume: 1000.0,
                bidPrice: 5040000.0,
                askPrice: 5060000.0,
                timestamp: Date()
            )
        ] : _mockCryptocurrencies
    }
}
