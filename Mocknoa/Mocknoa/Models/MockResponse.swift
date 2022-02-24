//
//  MockResponse.swift
//  Mocknoa
//
//  Created by Jonathan Torrens on 2/22/22.
//

import Foundation

public struct MockResponse: Codable, Hashable, Equatable {
    public var id: String = UUID().uuidString
    public var statusCode: UInt
    public var jsonString: String
    public var headers: [Header] = []

    public static var defaultResponseArray: [MockResponse] {
        let mockResponse = MockResponse(statusCode: 200, jsonString: "{}")
        return [mockResponse]
    }

    public static var endOfResponses404: MockResponse {
        let mockResponse = MockResponse(statusCode: 404, jsonString: "{\"message\": \"There are no more responses\"}")
        return mockResponse
    }
}

