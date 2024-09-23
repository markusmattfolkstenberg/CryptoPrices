//
//  to.swift
//  CryptoPriceModules
//
//  Created by Markus Mattfolk Stenberg on 2024-09-23.
//


import Foundation

// Define a protocol to mock URLSession
public protocol URLSessioning {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

// Extend URLSession to conform to the protocol
extension URLSession: URLSessioning {}
