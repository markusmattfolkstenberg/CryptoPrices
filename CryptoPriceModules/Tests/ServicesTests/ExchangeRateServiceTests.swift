//
//  ExchangeRateServiceTests.swift
//  CryptoPriceModules
//
//  Created by Markus Mattfolk Stenberg on 2024-09-22.
//

import XCTest
@testable import Services
@testable import Models

class ExchangeRateServiceTests: XCTestCase {

    var service: ExchangeRateService!
    var mockSession: URLSession!

    override func setUp() {
        super.setUp()
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        mockSession = URLSession(configuration: config)
        
        service = ExchangeRateService(session: mockSession)
    }

    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    func testFetchExchangeRateSuccess() async throws {
        let mockData = """
        {
            "result": "success",
            "time_last_update_unix": 1727065266,
            "time_next_update_unix": 1727155266,
            "base_code": "USD",
            "rates": {
                "USD": 1.0,
                "EUR": 0.85,
                "INR": 75.0
            }
        }
        """.data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, mockData)
        }
        
        let rate = try await service.fetchExchangeRate(for: "INR")
        
        XCTAssertEqual(rate, 75.0)
    }
    
    func testUsesCachedDataWhenValid() async throws {
        let cachedRates = ExchangeRates(
            baseCode: "USD", rates: ["USD": 1.0, "EUR": 0.85, "INR": 75.0],
            lastUpdateTime: Date(),
            nextUpdateTime: Date().addingTimeInterval(60 * 60)
        )
        
        service = ExchangeRateService(
            session: URLSession.shared,
            cachedExchangeRates: cachedRates,
            cacheExpirationDate: Date().addingTimeInterval(60 * 60)
        )
        
        MockURLProtocol.requestHandler = { _ in
            XCTFail("Network request should not be made when cache is valid")
            return (HTTPURLResponse(), Data())
        }

        let rate = try await service.fetchExchangeRate(for: "INR")
        XCTAssertEqual(rate, 75.0)
    }
    
    func testCacheIsUpdatedAfterFreshFetch() async throws {
        let expiredRates = ExchangeRates(
            baseCode: "USD", rates: ["USD": 1.0, "EUR": 0.85, "INR": 74.0],
            lastUpdateTime: Date().addingTimeInterval(-2 * 60 * 60),
            nextUpdateTime: Date().addingTimeInterval(-1 * 60 * 60)
        )
        
        service = ExchangeRateService(
            session: mockSession,
            cachedExchangeRates: expiredRates,
            cacheExpirationDate: Date().addingTimeInterval(-1 * 60 * 60)
        )
        
        let freshData = """
        {
            "result": "success",
            "time_last_update_unix": 1727065266,
            "time_next_update_unix": 1727155266,
            "base_code": "USD",
            "rates": {
                "USD": 1.0,
                "EUR": 0.85,
                "INR": 75.0
            }
        }
        """.data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, freshData)
        }

        let rate = try await service.fetchExchangeRate(for: "INR")
        XCTAssertEqual(rate, 75.0)
        
        let cachedRate = try await service.fetchExchangeRate(for: "INR")
        XCTAssertEqual(cachedRate, 75.0)     }


}
