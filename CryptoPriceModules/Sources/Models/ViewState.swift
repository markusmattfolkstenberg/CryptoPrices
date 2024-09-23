//
//  ViewState.swift
//  CryptoPriceModules
//
//  Created by Markus Mattfolk Stenberg on 2024-09-22.
//

import Foundation

public enum ViewState<T>: Equatable where T: Equatable {
    case loading
    case success(T)
    case error(Error)
    
    public static func ==(lhs: ViewState, rhs: ViewState) -> Bool {
            switch (lhs, rhs) {
            case (.loading, .loading):
                return true
            case let (.success(lhsValue), .success(rhsValue)):
                return lhsValue == rhsValue
            case let (.error(lhsError), .error(rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }
}
