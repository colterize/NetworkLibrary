//
//  Endpoint.swift
//  NetworkLibrary
//
//  Created by Yani . on 17/12/25.
//

import Foundation

public struct Endpoint {
    let path: String
    let method: HTTPMethod
    let headers: [String: String]?
    let body: [String: Any]?
    let encoding: BodyEncoding

    var url: URL {
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
