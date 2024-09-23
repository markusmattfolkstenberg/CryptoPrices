//
//  CryptocurrencyListViewModelTests.swift
//  CryptoPriceModules
//
//  Created by Markus Mattfolk Stenberg on 2024-09-23.
//

import XCTest
import SwiftUI
import Combine
import Mocks
@testable import Services
@testable import CryptocurrencyListFeature
@testable import Models
@testable import Common

class CryptocurrencyListViewModelTests: XCTestCase {
    var cryptocurrencyService: MockCryptocurrencyService!
    var exchangeRateService: MockExchangeRateService!
    var settingsService: MockSettingsService!
    var viewModel: CryptocurrencyListView.ViewModel!

    override func setUp() {
        super.setUp()

        cryptocurrencyService = MockCryptocurrencyService()
        exchangeRateService = MockExchangeRateService()
        settingsService = MockSettingsService()
    }

    override func tearDown() {
        cryptocurrencyService = nil
        exchangeRateService = nil
        settingsService = nil
        viewModel = nil

        super.tearDown()
    }

    @MainActor func testInitialization() {
        viewModel = CryptocurrencyListView.ViewModel(
            cryptocurrencyService: cryptocurrencyService,
            exchangeRateService: exchangeRateService,
            settingsService: settingsService
        )
        
        XCTAssertEqual(viewModel.viewState, .loading)
    }

    @MainActor func testLoadCryptocurrenciesSuccess() async {
        viewModel = CryptocurrencyListView.ViewModel(
            cryptocurrencyService: cryptocurrencyService,
            exchangeRateService: exchangeRateService,
            settingsService: settingsService
        )

        await cryptocurrencyService.setMockCryptocurrencies([
            Cryptocurrency(
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
                timestamp: Date()
            )
        ])

        let expectation = XCTestExpectation(description: "Load cryptocurrencies successfully")

        
        let cancellable = viewModel.$viewState.sink { state in
           if case .success = state {
               expectation.fulfill()
           }
       }
        await viewModel.loadCryptocurrencies()
        await fulfillment(of: [expectation], timeout: 5.0)

        if case let .success(displayModels) = viewModel.viewState {
            XCTAssertEqual(displayModels.count, 1)
            XCTAssertEqual(displayModels.first?.symbol, "BTCINR")
        }
        cancellable.cancel()

    }


    
    @MainActor func testLoadCryptocurrenciesError() async {
        viewModel = CryptocurrencyListView.ViewModel(
            cryptocurrencyService: cryptocurrencyService,
            exchangeRateService: exchangeRateService,
            settingsService: settingsService
        )

        let expectation = XCTestExpectation(description: "Load cryptocurrencies error state")

        let cancellable = viewModel.$viewState.sink { state in
            if case .error = state {
                expectation.fulfill()
            }
        }

        await cryptocurrencyService.setShouldThrowError(true)
        
        await viewModel.loadCryptocurrencies()
        
        await fulfillment(of: [expectation], timeout: 5.0)

        if case .error = viewModel.viewState {
        } else {
            XCTFail("Expected error state but got \(viewModel.viewState)")
        }

        cancellable.cancel()
    }


    
    @MainActor func testErrorRetry() async {
        viewModel = CryptocurrencyListView.ViewModel(
            cryptocurrencyService: cryptocurrencyService,
            exchangeRateService: exchangeRateService,
            settingsService: settingsService
        )

        await cryptocurrencyService.setShouldThrowError(true)
        await viewModel.loadCryptocurrencies()

        await cryptocurrencyService.setShouldThrowError(false)

        await cryptocurrencyService.setMockCryptocurrencies([
            Cryptocurrency(
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
                timestamp: Date()
            )
        ])

        let expectation = XCTestExpectation(description: "Retry loading cryptocurrencies successfully")

        let cancellable = viewModel.$viewState.sink { state in
            if case .success = state {
                expectation.fulfill()
            }
        }
        
        viewModel.onErrorRetry()

        await fulfillment(of: [expectation], timeout: 5.0)

        if case let .success(displayModels) = viewModel.viewState {
            XCTAssertEqual(displayModels.count, 1)
            XCTAssertEqual(displayModels.first?.symbol, "BTCINR")
        } else {
            XCTFail("Expected success state but got \(viewModel.viewState)")
        }

        cancellable.cancel()
    }


    
    @MainActor func testPullToRefresh() async {
        viewModel = CryptocurrencyListView.ViewModel(
            cryptocurrencyService: cryptocurrencyService,
            exchangeRateService: exchangeRateService,
            settingsService: settingsService
        )

        let expectation = XCTestExpectation(description: "Pull to refresh successfully loads cryptocurrencies")

        let cancellable = viewModel.$viewState.sink { state in
            if case .success = state {
                expectation.fulfill()
            }
        }

        await cryptocurrencyService.setMockCryptocurrencies([
            Cryptocurrency(
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
                timestamp: Date()
            )
        ])

        viewModel.onPullToRefresh()

        await fulfillment(of: [expectation], timeout: 5.0)

        if case let .success(displayModels) = viewModel.viewState {
            XCTAssertEqual(displayModels.count, 1)
            XCTAssertEqual(displayModels.first?.symbol, "BTCINR")
        } else {
            XCTFail("Expected success state but got \(viewModel.viewState)")
        }

        cancellable.cancel()
    }


    @MainActor func testDidTapSettings() {
        viewModel = CryptocurrencyListView.ViewModel(
            cryptocurrencyService: cryptocurrencyService,
            exchangeRateService: exchangeRateService,
            settingsService: settingsService
        )

        var outputReceived: CryptocurrencyListView.ViewModel.Output?

        viewModel.onOutPut = { output in
            outputReceived = output
        }

        viewModel.didTapSettings()

        XCTAssertEqual(outputReceived, .didTapSettings)
    }

}


extension CryptocurrencyListView.ViewModel.Output: Equatable {
    public static func == (lhs: CryptocurrencyListView.ViewModel.Output, rhs: CryptocurrencyListView.ViewModel.Output) -> Bool {
        switch (lhs, rhs) {
        case (.didTapSettings, didTapSettings):
            return true
        case (.didSelect(let a), .didSelect(let b)):
            return a == b
        case (.didTapSettings, didSelect), (.didSelect, didTapSettings):
            return false
        }
    }
    
    
}
