//
//  ExchangeRateService.swift
//  CryptoPrice
//
//  Created by Markus Mattfolk Stenberg on 2024-09-22.
//
import Foundation
import Models

public protocol ExchangeRateServicing: Actor {
    func fetchExchangeRate(for currency: String) async throws -> Double
}

public actor ExchangeRateService: ExchangeRateServicing {
    private var cachedExchangeRates: ExchangeRates?
    private var cacheExpirationDate: Date?
    
    private let session: URLSession
    private let urlString = "https://open.er-api.com/v6/latest/USD"

    // Accept a session to allow for injection during testing
    public init(session: URLSession = .shared, cachedExchangeRates: ExchangeRates? = nil, cacheExpirationDate: Date? = nil) {
        self.session = session
        self.cachedExchangeRates = cachedExchangeRates
        self.cacheExpirationDate = cacheExpirationDate
    }
    
    // Fetch the exchange rate for a specific currency
    public func fetchExchangeRate(for currency: String) async throws -> Double {
        let exchangeRates = try await fetchExchangeRates() // Fetch exchange rates
        
        // Try to retrieve the rate for the specified currency
        guard let rate = exchangeRates.rates[currency.uppercased()] else {
            throw ExchangeRateError.currencyNotFound(currency) // Handle missing currency
        }
        
        return rate
    }

    // Fetch exchange rates from the API or cache
    private func fetchExchangeRates() async throws -> ExchangeRates {
        let currentDate = Date()
        
        // Return cached rates if they exist and are still valid
        if let expirationDate = cacheExpirationDate, currentDate < expirationDate, let cachedRates = cachedExchangeRates {
            return cachedRates
        }
        
        // API call to get fresh rates
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        let (data, response) = try await session.data(from: url)  // Use the injected session

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }

        // Decode the response into ExchangeRates
        do {
            let decoder = JSONDecoder()
            let exchangeRates = try decoder.decode(ExchangeRates.self, from: data)
            
            // Cache the new exchange rates and expiration time
            self.cachedExchangeRates = exchangeRates
            self.cacheExpirationDate = exchangeRates.nextUpdateTime
            
            return exchangeRates
        } catch {
            throw NetworkError.decodingError
        }
    }
}

public enum ExchangeRateError: Error, LocalizedError, Equatable {
    case currencyNotFound(String)

    public var errorDescription: String? {
        switch self {
        case .currencyNotFound(let currency):
            return "The exchange rate for \(currency) could not be found."
        }
    }
    
    public static func == (lhs: ExchangeRateError, rhs: ExchangeRateError) -> Bool {
        lhs.errorDescription == rhs.errorDescription
    }
}
