//
//  ExchangeRatesTests.swift
//  CryptoPriceModules
//
//  Created by Markus Mattfolk Stenberg on 2024-09-23.
//


import XCTest
@testable import Models

class ExchangeRatesTests: XCTestCase {

    func testDecodingFromJSON() throws {
        let jsonData = """
        {
            "base_code": "USD",
            "rates": {
                "USD": 1.0,
                "EUR": 0.85,
                "INR": 75.0
            },
            "time_last_update_unix": 1727065266,
            "time_next_update_unix": 1727155266
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let exchangeRates = try decoder.decode(ExchangeRates.self, from: jsonData)
        
        XCTAssertEqual(exchangeRates.baseCode, "USD")
        XCTAssertEqual(exchangeRates.rates["USD"], 1.0)
        XCTAssertEqual(exchangeRates.rates["EUR"], 0.85)
        XCTAssertEqual(exchangeRates.rates["INR"], 75.0)
        
        let expectedLastUpdateTime = Date(timeIntervalSince1970: 1727065266)
        let expectedNextUpdateTime = Date(timeIntervalSince1970: 1727155266)
        
        XCTAssertEqual(exchangeRates.lastUpdateTime, expectedLastUpdateTime)
        XCTAssertEqual(exchangeRates.nextUpdateTime, expectedNextUpdateTime)
    }
    
    func testManualInitialization() {
        let baseCode = "USD"
        let rates: [String: Double] = ["USD": 1.0, "EUR": 0.85, "INR": 75.0]
        let lastUpdateTime = Date(timeIntervalSince1970: 1727065266)
        let nextUpdateTime = Date(timeIntervalSince1970: 1727155266)
        
        let exchangeRates = ExchangeRates(baseCode: baseCode, rates: rates, lastUpdateTime: lastUpdateTime, nextUpdateTime: nextUpdateTime)
        
        XCTAssertEqual(exchangeRates.baseCode, baseCode)
        XCTAssertEqual(exchangeRates.rates, rates)
        XCTAssertEqual(exchangeRates.lastUpdateTime, lastUpdateTime)
        XCTAssertEqual(exchangeRates.nextUpdateTime, nextUpdateTime)
    }

    func testDecodingMissingRatesField() throws {
        let jsonData = """
        {
            "base_code": "USD",
            "time_last_update_unix": 1727065266,
            "time_next_update_unix": 1727155266
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        
        XCTAssertThrowsError(try decoder.decode(ExchangeRates.self, from: jsonData)) { error in
            guard case DecodingError.keyNotFound(let key, _) = error else {
                return XCTFail("Expected keyNotFound error but got: \(error)")
            }
            XCTAssertEqual(key.stringValue, "rates")
        }
    }

    func testDecodingInvalidDateFormat() throws {
        let jsonData = """
        {
            "base_code": "USD",
            "rates": {
                "USD": 1.0,
                "EUR": 0.85,
                "INR": 75.0
            },
            "time_last_update_unix": "invalid_timestamp",
            "time_next_update_unix": "invalid_timestamp"
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        
        XCTAssertThrowsError(try decoder.decode(ExchangeRates.self, from: jsonData)) { error in
            guard case DecodingError.typeMismatch(let type, _) = error else {
                return XCTFail("Expected typeMismatch error but got: \(error)")
            }
            XCTAssertTrue(type == TimeInterval.self)
        }
    }

}
