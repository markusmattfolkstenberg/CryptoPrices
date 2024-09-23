//
//  MockExchangeRateService.swift
//  CryptoPriceModules
//
//  Created by Markus Mattfolk Stenberg on 2024-09-22.
//
import Foundation
import Services
import Models

final public actor MockExchangeRateService: ExchangeRateServicing {
    public init(){}
    
    public func fetchExchangeRate(for currency: String) async throws -> Double {
        return 0.012
    }
}
