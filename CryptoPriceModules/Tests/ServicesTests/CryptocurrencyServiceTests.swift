//
//  CryptocurrencyServiceTests.swift
//  CryptoPriceModules
//
//  Created by Markus Mattfolk Stenberg on 2024-09-22.
//


import XCTest
@testable import Services
@testable import Models

class CryptocurrencyServiceTests: XCTestCase {
    
    var service: CryptocurrencyService!
    
    override func setUp() {
        super.setUp()
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let mockSession = URLSession(configuration: config)
        
        service = CryptocurrencyService(session: mockSession)
    }
    
    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }
    
    func testFetchCryptocurrenciesSuccess() async throws {
        let mockData = """
        [
            {
                "symbol": "btcinr",
                "baseAsset": "btc",
                "quoteAsset": "inr",
                "openPrice": "5000000",
                "lowPrice": "4800000",
                "highPrice": "5100000",
                "lastPrice": "5050000",
                "volume": "100",
                "bidPrice": "5040000",
                "askPrice": "5060000",
                "at": 1727065266000
            }
        ]
        """.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, mockData)
        }
        
        let cryptos = try await service.fetchCryptocurrencies()
        
        XCTAssertEqual(cryptos.count, 1)
        XCTAssertEqual(cryptos.first?.symbol, "btcinr")
        XCTAssertEqual(cryptos.first?.lastPrice, 5050000)
    }
    
    func testFetchCryptocurrenciesInvalidResponse() async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: 500,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, Data())
        }
        
        do {
            _ = try await service.fetchCryptocurrencies()
            XCTFail("Expected to throw invalidResponse error, but no error was thrown")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.invalidResponse)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testFetchCryptocurrenciesInvalidURL() async {
        service = CryptocurrencyService(session: URLSession.shared, url: "")
        
        do {
            _ = try await service.fetchCryptocurrencies()
            XCTFail("Expected to throw invalidURL error, but no error was thrown")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.invalidURL)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
}
