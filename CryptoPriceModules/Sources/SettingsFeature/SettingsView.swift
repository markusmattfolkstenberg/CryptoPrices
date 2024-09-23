//
//  OptionsView.swift
//  CryptoPrice
//
//  Created by Markus Mattfolk Stenberg on 2024-09-22.
//

import SwiftUI
import Models
import Common
import Services

public struct SettingsView: View {
    @ObservedObject var viewModel: ViewModel

    
    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Default Currency")) {
                    Picker("Currency", selection: $viewModel.selectedCurrency) {
                        ForEach(Currency.allCases) { currency in
                            Text(currency.symbol).tag(currency)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationTitle("Settings")
            .toolbar{
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.onCancelTapped()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        viewModel.onSaveTapped()
                    }
                }
            }
        }
    }
}

extension SettingsView {
    @MainActor
    public final class ViewModel: ObservableObject, Hashable, Identifiable {
        
        public enum Output: Sendable {
            case cancelTapped
            case saveTapped
        }
        
        public var onOutput: (Output) -> Void = { _ in }
        
        @Published var selectedCurrency: Currency
        
        private let settingsService: SettingsServicing
        
        public init(settingsService: SettingsServicing, onOutput: @escaping (Output) -> Void) {
            self.settingsService = settingsService
            self.onOutput = onOutput
            self.selectedCurrency = Currency(rawValue: settingsService.getPreferredCurrency()) ?? .usd
        }
        
        func onCancelTapped() {
            onOutput(.cancelTapped)
        }
        
        func onSaveTapped() {
            settingsService.setPreferredCurrency(selectedCurrency)
            onOutput(.saveTapped)
        }
    }
}
