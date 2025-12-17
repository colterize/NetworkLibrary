// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

@available(macOS 10.15.0, *)
@available(iOS 13.0.0, *)
protocol APIClientProtocol {
    func sendRequest(endpoint: Endpoint) async throws -> Data
}

@available(macOS 10.15.0, *)
@available(iOS 13.0.0, *)
final public class APIClient: APIClientProtocol, Sendable {
    @MainActor public static let shared = APIClient()
    private let session: URLSession

    public init() {
        self.session = URLSession.shared
    }

    public func sendRequest(endpoint: Endpoint) async throws -> Data {
        var request = URLRequest(url: endpoint.url, timeoutInterval: Double.infinity)
        request.httpMethod = endpoint.method.rawValue

        if let header = endpoint.headers {
            request.allHTTPHeaderFields = setHttpHeader(endpoint.encoding, with: header)
        }

        if let body = endpoint.body {
            request.httpBody = setHttpBody(endpoint.encoding, with: body)
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.init(rawValue: httpResponse.statusCode))
        }

        return data
    }

    private func setHttpHeader(_ encoding: BodyEncoding, with header: [String: String]) -> [String: String] {
        var httpHeader: [String: String] = [:]
        switch encoding {
        case .json:
            httpHeader = header
            httpHeader.updateValue("application/json", forKey: "Content-Type")
        case .formURLEncoded:
            httpHeader = header
            httpHeader.updateValue("application/x-www-form-urlencoded", forKey: "Content-Type")
        }
        return httpHeader
    }

    private func setHttpBody(_ encoding: BodyEncoding, with body: [String: Any]) -> Data? {
        var httpBody: Data?
        switch encoding {
        case .json:
            httpBody = try? JSONSerialization.data(withJSONObject: body)
            print("body :", body)
        case .formURLEncoded:
            let formString = body
                .map { "\($0.key)=\("\($0.value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
                .joined(separator: "&")
            httpBody = formString.data(using: .utf8)
            print("body :", formString)
        }
        return httpBody
    }
}
