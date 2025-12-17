//
//  Endpoint.swift
//  NetworkLibrary
//
//  Created by Yani . on 17/12/25.
//

import Foundation

public struct Endpoint {
    public let path: String
    public let method: HTTPMethod
    public let headers: [String: String]?
    public let body: [String: Any]?
    public let encoding: BodyEncoding

    public var url: URL {
        return URL(string: path)!
    }
}

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public enum BodyEncoding {
    case json
    case formURLEncoded
}
