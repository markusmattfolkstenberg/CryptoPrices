//
//  NetworkError.swift
//  CryptoPrice
//
//  Created by Markus Mattfolk Stenberg on 2024-09-22.
//

import Foundation

public enum NetworkError: Error, LocalizedError, Equatable{
    
    case invalidURL
    case invalidResponse
    case decodingError
    case other(Error)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .invalidResponse:
            return "Invalid response from the server."
        case .decodingError:
            return "Failed to decode the response."
        case .other(let error):
            return error.localizedDescription
        }
    }
    
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        lhs.errorDescription == rhs.errorDescription
    }
}
