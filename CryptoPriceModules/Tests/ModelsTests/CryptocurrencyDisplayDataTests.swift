//
//  CryptocurrencyDisplayDataTests.swift
//  CryptoPriceModules
//
//  Created by Markus Mattfolk Stenberg on 2024-09-22.
//


import XCTest
@testable import Models

class CryptocurrencyDisplayDataTests: XCTestCase {
    
    func testManualInitialization() {
        let id = UUID()
        let symbol = "BTC"
        let name = "Bitcoin"
        let lastPrice = "$50000.00"
        let priceChange = "2.00%"
        let volume = "1000"
        let bidPrice = "$49900.00"
        let askPrice = "$50100.00"
        let openPrice = "$48000.00"
        let highPrice = "$51000.00"
        let lowPrice = "$47000.00"
        let timestamp = "Sep 20, 2024, 10:00 AM"
        
        let displayData = CryptocurrencyDisplayData(
            id: id,
            symbol: symbol,
            name: name,
            lastPrice: lastPrice,
            priceChange: priceChange,
            volume: volume,
            bidPrice: bidPrice,
            askPrice: askPrice,
            openPrice: openPrice,
            highPrice: highPrice,
            lowPrice: lowPrice,
            timestamp: timestamp
        )
        
        XCTAssertEqual(displayData.id, id)
        XCTAssertEqual(displayData.symbol, symbol)
        XCTAssertEqual(displayData.name, name)
        XCTAssertEqual(displayData.lastPrice, lastPrice)
        XCTAssertEqual(displayData.priceChange, priceChange)
        XCTAssertEqual(displayData.volume, volume)
        XCTAssertEqual(displayData.bidPrice, bidPrice)
        XCTAssertEqual(displayData.askPrice, askPrice)
        XCTAssertEqual(displayData.openPrice, openPrice)
        XCTAssertEqual(displayData.highPrice, highPrice)
        XCTAssertEqual(displayData.lowPrice, lowPrice)
        XCTAssertEqual(displayData.timestamp, timestamp)
    }
    
    func testConvenienceInitializer() {
        let cryptocurrency = Cryptocurrency(
            symbol: "btcinr",
            baseAsset: "btc",
            quoteAsset: "inr",
            openPrice: 5000000.0,
            lowPrice: 4800000.0,
            highPrice: 5100000.0,
            lastPrice: 5050000.0,
            volume: 1000.0,
            bidPrice: 5040000.0,
            askPrice: 5060000.0,
            timestamp: Date(timeIntervalSince1970: 1727065266)
        )
        let exchangeRate = 0.012
        let currencyCode = "USD"
        
        let displayData = CryptocurrencyDisplayData(from: cryptocurrency, exchangeRate: exchangeRate, currencyCode: currencyCode)
        
        XCTAssertEqual(displayData.symbol, "BTCINR")
        XCTAssertEqual(displayData.name, "BTC/INR")
        
        let expectedLastPrice = CurrencyFormatter.format(value: 5050000.0 * exchangeRate, for: currencyCode)
        XCTAssertEqual(displayData.lastPrice, expectedLastPrice)
        
        let expectedPriceChangePercent = ((5050000.0 - 5000000.0) / 5000000.0) * 100
        XCTAssertEqual(displayData.priceChange, String(format: "%.2f%%", expectedPriceChangePercent))
        
        let volumeFormatter = NumberFormatter()
        volumeFormatter.numberStyle = .decimal
        let expectedVolume = volumeFormatter.string(from: NSNumber(value: cryptocurrency.volume))  
        XCTAssertEqual(displayData.volume, expectedVolume)
        
        XCTAssertEqual(displayData.bidPrice, CurrencyFormatter.format(value: 5040000.0, for: currencyCode))
        XCTAssertEqual(displayData.askPrice, CurrencyFormatter.format(value: 5060000.0, for: currencyCode))
        XCTAssertEqual(displayData.openPrice, CurrencyFormatter.format(value: 5000000.0, for: currencyCode))
        XCTAssertEqual(displayData.highPrice, CurrencyFormatter.format(value: 5100000.0, for: currencyCode))
        XCTAssertEqual(displayData.lowPrice, CurrencyFormatter.format(value: 4800000.0, for: currencyCode))
        
        let expectedTimestamp = CryptocurrencyDisplayData.formatDate(cryptocurrency.timestamp)
        XCTAssertEqual(displayData.timestamp, expectedTimestamp)
    }

    
    func testFormatDate() {
        let date = Date(timeIntervalSince1970: 1727065266)
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        let expectedFormattedDate = formatter.string(from: date)
        let formattedDate = CryptocurrencyDisplayData.formatDate(date)
        
        XCTAssertEqual(formattedDate, expectedFormattedDate)
    }
    
    func testFormatDateNil() {
        let date: Date? = nil
        
        let formattedDate = CryptocurrencyDisplayData.formatDate(date)
        
        XCTAssertEqual(formattedDate, "N/A")
    }
}

class CurrencyFormatterTests: XCTestCase {
    
    func testCurrencyFormatter_USD() {
        let value: Double = 5050000.0
        let formattedValue = CurrencyFormatter.format(value: value, for: "USD")
        XCTAssertEqual(formattedValue, "$5,050,000.00")  // Assuming en_US formatting
    }
    
    func testCurrencyFormatter_SEK() {
        let value: Double = 5050000.0
        let formattedValue = CurrencyFormatter.format(value: value, for: "SEK")
        XCTAssertEqual(formattedValue, "5 050 000,00 kr")  // Assuming sv_SE formatting
    }
}
