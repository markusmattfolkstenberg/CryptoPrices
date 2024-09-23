//
//  ErrorView.swift
//  CryptoPrice
//
//  Created by Markus Mattfolk Stenberg on 2024-09-22.
//

import SwiftUI

public struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    public init(message: String, retryAction: @escaping () -> Void) {
        self.message = message
        self.retryAction = retryAction
    }

    public var body: some View {
        VStack {
            Text("Error:")
                .font(.headline)
            Text(message)
                .multilineTextAlignment(.center)
                .padding()
            Button("Retry") {
                retryAction()
            }
            .padding()
        }
    }
}

