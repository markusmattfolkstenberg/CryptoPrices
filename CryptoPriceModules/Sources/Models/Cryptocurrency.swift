//
//  Cryptocurrency.swift
//  CryptoPrice
//
//  Created by Markus Mattfolk Stenberg on 2024-09-22.
//

import Foundation

public struct Cryptocurrency: Decodable, Equatable, Sendable {
    public let symbol: String
    public let baseAsset: String
    public let quoteAsset: String
    public let openPrice: Double
    public let lowPrice: Double
    public let highPrice: Double
    public let lastPrice: Double
    public let volume: Double
    public let bidPrice: Double
    public let askPrice: Double
    public let timestamp: Date?

    enum CodingKeys: String, CodingKey {
        case symbol, baseAsset, quoteAsset, openPrice, lowPrice, highPrice, lastPrice, volume, bidPrice, askPrice, at
    }
    
    public init (symbol: String, baseAsset: String, quoteAsset: String, openPrice: Double, lowPrice: Double, highPrice: Double, lastPrice: Double, volume: Double, bidPrice: Double, askPrice: Double, timestamp: Date?) {
        self.symbol = symbol
        self.baseAsset = baseAsset
        self.quoteAsset = quoteAsset
        self.openPrice = openPrice
        self.lowPrice = lowPrice
        self.highPrice = highPrice
        self.lastPrice = lastPrice
        self.volume = volume
        self.bidPrice = bidPrice
        self.askPrice = askPrice
        self.timestamp = timestamp
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        symbol = try container.decode(String.self, forKey: .symbol)
        baseAsset = try container.decode(String.self, forKey: .baseAsset)
        quoteAsset = try container.decode(String.self, forKey: .quoteAsset)

        openPrice = try Self.decodePrice(container: container, key: .openPrice)!
        lowPrice = try Self.decodePrice(container: container, key: .lowPrice)!
        highPrice = try Self.decodePrice(container: container, key: .highPrice)!
        lastPrice = try Self.decodePrice(container: container, key: .lastPrice)!
        volume = try Self.decodePrice(container: container, key: .volume)!
        bidPrice = try Self.decodePrice(container: container, key: .bidPrice)!
        askPrice = try Self.decodePrice(container: container, key: .askPrice)!

        if let timestampMilliseconds = try container.decodeIfPresent(Int64.self, forKey: .at) {
            timestamp = Date(timeIntervalSince1970: TimeInterval(timestampMilliseconds) / 1000)
        } else {
            timestamp = nil
        }
    }

    // Helper function to decode prices that might be strings or numbers
    private static func decodePrice(container: KeyedDecodingContainer<CodingKeys>, key: CodingKeys) throws -> Double? {
        if let stringValue = try? container.decodeIfPresent(String.self, forKey: key) {
            return Double(stringValue)
        } else if let doubleValue = try? container.decodeIfPresent(Double.self, forKey: key) {
            return doubleValue
        }
        return nil
    }
}
