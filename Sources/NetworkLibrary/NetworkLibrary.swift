// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

@available(macOS 10.15.0, *)
@available(iOS 13.0.0, *)
protocol APIClientProtocol {
    func sendRequest<T: Decodable>(endpoint: Endpoint) async throws -> T
    func sendDynamicRequest(endpoint: Endpoint) async throws -> Any
}

@available(macOS 10.15.0, *)
@available(iOS 13.0.0, *)
final public class APIClient: APIClientProtocol {
    @MainActor public static let shared = APIClient()
    private let session: URLSession

    public init() {
        self.session = URLSession.shared
    }

    public func sendRequest<T>(endpoint: Endpoint) async throws -> T where T : Decodable {
        var request = URLRequest(url: endpoint.url, timeoutInterval: Double.infinity)
        request.httpMethod = endpoint.method.rawValue

        print("endpoint :", endpoint.url)
        print("method :", endpoint.method.rawValue)

        if let header = endpoint.headers {
            request.allHTTPHeaderFields = setHttpHeader(endpoint.encoding, with: header)
            print("header :", request.allHTTPHeaderFields ?? [:])
        }

        if let body = endpoint.body {
            request.httpBody = setHttpBody(endpoint.encoding, with: body)
        }

        let (data, response) = try await session.data(for: request)

        guard response is HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        do {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXX"
            formatter.locale = Locale(identifier: "en_US_POSIX")

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(formatter)

            let decoded = try decoder.decode(T.self, from: data)
            print("result :", decoded)
            return decoded
        } catch {
            print("decode error:", error)
            throw URLError(.cannotDecodeContentData)
        }
    }

    public func sendDynamicRequest(endpoint: Endpoint) async throws -> Any {
        var request = URLRequest(url: endpoint.url, timeoutInterval: Double.infinity)
        request.httpMethod = endpoint.method.rawValue

        print("endpoint :", endpoint.url)
        print("method :", endpoint.method.rawValue)

        if let header = endpoint.headers {
            request.allHTTPHeaderFields = setHttpHeader(endpoint.encoding, with: header)
            print("header :", request.allHTTPHeaderFields ?? [:])
        }

        if let body = endpoint.body {
            request.httpBody = setHttpBody(endpoint.encoding, with: body)
        }

        let (data, response) = try await session.data(for: request)

        guard response is HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            print("json:", json)
            return json
        } catch {
            print("decode error:", error)
            throw URLError(.cannotDecodeContentData)
        }
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
