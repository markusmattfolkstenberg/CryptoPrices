//
//  CryptocurrencyDetailsView.swift
//  CryptoPrice
//
//  Created by Markus Mattfolk Stenberg on 2024-09-22.
//

import SwiftUI
import Common
import Models

public struct CryptocurrencyDetailsView: View {
    @ObservedObject var viewModel: CryptocurrencyDetailsView.ViewModel

    public init(viewModel: CryptocurrencyDetailsView.ViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(viewModel.cryptocurrency.name)
                    .font(.largeTitle)
                    .bold()
                
                detailsRow(label: "Symbol", value: viewModel.cryptocurrency.symbol)
                detailsRow(label: "Last Price", value: viewModel.cryptocurrency.lastPrice)
                detailsRow(label: "Price Change", value: viewModel.cryptocurrency.priceChange)
                detailsRow(label: "Volume", value: viewModel.cryptocurrency.volume)
                detailsRow(label: "Bid Price", value: viewModel.cryptocurrency.bidPrice)
                detailsRow(label: "Ask Price", value: viewModel.cryptocurrency.askPrice)
                detailsRow(label: "Open Price", value: viewModel.cryptocurrency.openPrice)
                detailsRow(label: "High Price", value: viewModel.cryptocurrency.highPrice)
                detailsRow(label: "Low Price", value: viewModel.cryptocurrency.lowPrice)
                detailsRow(label: "Timestamp", value: viewModel.cryptocurrency.timestamp)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Details")
    }

    @ViewBuilder
    private func detailsRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.headline)
            Spacer()
            Text(value)
                .font(.subheadline)
        }
        .padding(.vertical, 4)
    }
}

extension CryptocurrencyDetailsView {
    @MainActor
    public final class ViewModel: ObservableObject, Hashable, Identifiable {
        public let cryptocurrency: CryptocurrencyDisplayData

        public init(cryptocurrency: CryptocurrencyDisplayData) {
            self.cryptocurrency = cryptocurrency
        }
    }
}
