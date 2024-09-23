//
//  Currency.swift
//  CryptoPrice
//
//  Created by Markus Mattfolk Stenberg on 2024-09-22.
//

import Foundation

public enum Currency: String, CaseIterable, Identifiable, Codable {
    case usd = "USD"
    case sek = "SEK"

    public var id: String { rawValue }
    public var symbol: String { rawValue }
}
