//
//  File.swift
//  CryptoPriceModules
//
//  Created by Markus Mattfolk Stenberg on 2024-09-20.
//

import Foundation

public struct CryptocurrencyDisplayData: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let symbol: String
    public let name: String
    public let lastPrice: String
    public let priceChange: String
    public let volume: String
    public let bidPrice: String
    public let askPrice: String
    public let openPrice: String
    public let highPrice: String
    public let lowPrice: String
    public let timestamp: String

    public init(
        id: UUID = UUID(),
        symbol: String,
        name: String,
        lastPrice: String,
        priceChange: String,
        volume: String,
        bidPrice: String,
        askPrice: String,
        openPrice: String,
        highPrice: String,
        lowPrice: String,
        timestamp: String
    ) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.lastPrice = lastPrice
        self.priceChange = priceChange
        self.volume = volume
        self.bidPrice = bidPrice
        self.askPrice = askPrice
        self.openPrice = openPrice
        self.highPrice = highPrice
        self.lowPrice = lowPrice
        self.timestamp = timestamp
    }

    // Convenience initializer with the original cryptocurrency data and the exchange rate
    public init(from cryptocurrency: Cryptocurrency, exchangeRate: Double, currencyCode: String) {
        self.id = UUID()
        self.symbol = cryptocurrency.symbol.uppercased()
        self.name = "\(cryptocurrency.baseAsset.uppercased())/\(cryptocurrency.quoteAsset.uppercased())"
        
        // Compute the price change percentage
        let priceChangePercent = ((cryptocurrency.lastPrice - cryptocurrency.openPrice) / cryptocurrency.openPrice) * 100
        
        // Format the prices using the currency formatter
        self.lastPrice = CurrencyFormatter.format(value: cryptocurrency.lastPrice * exchangeRate, for: currencyCode)
        self.priceChange = String(format: "%.2f%%", priceChangePercent)
        
        // Format volume as a regular number
        self.volume = NumberFormatter.localizedString(from: NSNumber(value: cryptocurrency.volume), number: .decimal)
        
        self.bidPrice = CurrencyFormatter.format(value: cryptocurrency.bidPrice, for: currencyCode)
        self.askPrice = CurrencyFormatter.format(value: cryptocurrency.askPrice, for: currencyCode)
        self.openPrice = CurrencyFormatter.format(value: cryptocurrency.openPrice, for: currencyCode)
        self.highPrice = CurrencyFormatter.format(value: cryptocurrency.highPrice, for: currencyCode)
        self.lowPrice = CurrencyFormatter.format(value: cryptocurrency.lowPrice, for: currencyCode)
        self.timestamp = CryptocurrencyDisplayData.formatDate(cryptocurrency.timestamp)
    }

    // Helper method to format Date to a human-readable string
    public static func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        return formatter.string(from: date)
    }}

struct CurrencyFormatter {
    static func format(value: Double, for currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        
        // Map currency codes to their corresponding locales
        switch currencyCode.uppercased() {
        case "USD":
            formatter.locale = Locale(identifier: "en_US")
        case "SEK":
            formatter.locale = Locale(identifier: "sv_SE")
        default:
            formatter.locale = Locale.current  // Default to the current locale if unknown
        }

        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

