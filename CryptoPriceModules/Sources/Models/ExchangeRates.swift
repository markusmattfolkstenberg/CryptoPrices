//
//  ExchangeRates.swift
//  CryptoPrice
//
//  Created by Markus Mattfolk Stenberg on 2024-09-22.
//

import Foundation

public struct ExchangeRates: Decodable {
    public let baseCode: String
    public let rates: [String: Double]
    public let lastUpdateTime: Date
    public let nextUpdateTime: Date

    enum CodingKeys: String, CodingKey {
        case baseCode = "base_code"
        case rates
        case lastUpdateUnix = "time_last_update_unix"
        case nextUpdateUnix = "time_next_update_unix"
    }

    // Custom init to decode the timestamps as Dates
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.baseCode = try container.decode(String.self, forKey: .baseCode)
        self.rates = try container.decode([String: Double].self, forKey: .rates)

        let lastUpdateTimestamp = try container.decode(TimeInterval.self, forKey: .lastUpdateUnix)
        self.lastUpdateTime = Date(timeIntervalSince1970: lastUpdateTimestamp)

        let nextUpdateTimestamp = try container.decode(TimeInterval.self, forKey: .nextUpdateUnix)
        self.nextUpdateTime = Date(timeIntervalSince1970: nextUpdateTimestamp)
    }
    
    public init (baseCode: String, rates: [String: Double], lastUpdateTime: Date, nextUpdateTime: Date) {
        self.baseCode = baseCode
        self.rates = rates
        self.lastUpdateTime = lastUpdateTime
        self.nextUpdateTime = nextUpdateTime
    }
}
