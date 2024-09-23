//
//  CryptocurrencyListCoordinatorViewModelTests.swift
//  CryptoPriceModules
//
//  Created by Markus Mattfolk Stenberg on 2024-09-23.
//
import XCTest
import Mocks
@testable import Services
@testable import CryptocurrencyListFeature
@testable import Models
@testable import Common

class CryptocurrencyListCoordinatorViewModelTests: XCTestCase {
    var cryptocurrencyService: MockCryptocurrencyService!
    var exchangeRateService: MockExchangeRateService!
    var settingsService: MockSettingsService!
    var viewModel: CryptocurrencyListCoordinatorView.ViewModel!

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
        viewModel = CryptocurrencyListCoordinatorView.ViewModel(
            cryptocurrencyService: cryptocurrencyService,
            exchangeRateService: exchangeRateService,
            settingsService: settingsService
        )
        
        XCTAssertEqual(viewModel.activeRootPage, .list(viewModel.cryptoCurrencyListViewmodel))
        XCTAssertTrue(viewModel.pageStack.isEmpty)
    }
    
    @MainActor func testDidSelectCryptocurrency() {
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
            timestamp: Date()
        )
        
        viewModel = CryptocurrencyListCoordinatorView.ViewModel(
            cryptocurrencyService: cryptocurrencyService,
            exchangeRateService: exchangeRateService,
            settingsService: settingsService
        )
        
        let cryptocurrencyDisplayData = CryptocurrencyDisplayData(
            from: cryptocurrency,
            exchangeRate: 0.012,
            currencyCode: "USD"
        )
        
        viewModel.cryptoCurrencyListViewmodel.didSelect(cryptocurrencyDisplayData)
        
        XCTAssertEqual(viewModel.pageStack.count, 1)
        
        if case let .details(detailsViewModel) = viewModel.pageStack.first {
            XCTAssertNotNil(detailsViewModel)

            XCTAssertEqual(detailsViewModel.cryptocurrency.symbol, cryptocurrencyDisplayData.symbol)
        } else {
            XCTFail("Expected details view but got \(String(describing: viewModel.pageStack.first))")
        }
    }


    
    @MainActor func testDidTapSettings() {
        var outputReceived: CryptocurrencyListCoordinatorView.ViewModel.Output?
        
        viewModel = CryptocurrencyListCoordinatorView.ViewModel(
            cryptocurrencyService: cryptocurrencyService,
            exchangeRateService: exchangeRateService,
            settingsService: settingsService
        )
        
        viewModel.onOutPut = { output in
            outputReceived = output
        }
        
        viewModel.cryptoCurrencyListViewmodel.didTapSettings()
        
        XCTAssertEqual(outputReceived, .didTapSettings)
    }
}
