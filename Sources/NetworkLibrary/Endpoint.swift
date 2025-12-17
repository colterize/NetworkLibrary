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

    public init(path: String, method: HTTPMethod, headers: [String: String]?, body: [String: Any]?, encoding: BodyEncoding) {
        self.path = path
        self.method = method
        self.headers = headers
        self.body = body
        self.encoding = encoding
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

public extension Endpoint {

}
