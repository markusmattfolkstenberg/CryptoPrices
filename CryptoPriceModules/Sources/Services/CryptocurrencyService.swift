//
//  CryptocurrencyService.swift
//  CryptoPrice
//
//  Created by Markus Mattfolk Stenberg on 2024-09-22.
//
import Foundation
import Models

public protocol CryptocurrencyServicing: Actor {
    func fetchCryptocurrencies() async throws -> [Cryptocurrency]
}

public actor CryptocurrencyService: CryptocurrencyServicing {
    private let session: URLSession
    private let urlString: String
    
    public init(session: URLSession = .shared, url: String = "https://api.wazirx.com/sapi/v1/tickers/24hr") {
        self.session = session
        self.urlString = url
    }
    
    public func fetchCryptocurrencies() async throws -> [Cryptocurrency] {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode([Cryptocurrency].self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
}
