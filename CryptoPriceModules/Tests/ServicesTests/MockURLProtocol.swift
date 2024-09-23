//
//  MockURLProtocol.swift
//  CryptoPriceModules
//
//  Created by Markus Mattfolk Stenberg on 2024-09-23.
//


import Foundation

class MockURLProtocol: URLProtocol {
    nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        // Intercept all network requests
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("Request handler is not set.")
        }

        do {
            // Get the mock response and data from the handler
            let (response, data) = try handler(request)
            // Simulate receiving the response
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            // Simulate loading the data
            self.client?.urlProtocol(self, didLoad: data)
            // Notify that the request finished loading
            self.client?.urlProtocolDidFinishLoading(self)
        } catch {
            // Simulate an error
            self.client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {
        // No need to implement
    }
}
