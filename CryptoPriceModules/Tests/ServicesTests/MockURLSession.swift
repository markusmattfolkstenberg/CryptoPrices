//
//  MockURLSession.swift
//  CryptoPriceModules
//
//  Created by Markus Mattfolk Stenberg on 2024-09-22.
//

@testable import Services
import Foundation


class MockURLSession: URLSessioning {
    var mockData: Data?
    var mockError: Error?

    func data(from url: URL) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }

        guard let mockData = mockData else {
            throw NetworkError.invalidResponse
        }

        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (mockData, response)
    }
}
