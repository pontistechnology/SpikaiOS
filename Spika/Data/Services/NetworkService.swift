//
//  NetworkService.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import Foundation
import Combine
import UIKit

enum RequestType: String {
    case GET, PUT, POST, DELETE
}

enum NetworkError: Error {
    case badURL, requestFailed, fileTooLarge, unknown, noAccessToken, chunkUploadFail, verifyFileFail

    var description : String {
        switch self {
        case .badURL: return "Bad URL."
        case .requestFailed: return "Request Failed."
        case .fileTooLarge: return "File too large."
        case .unknown: return "Unknown error."
        case .noAccessToken: return "No access token."
        case .chunkUploadFail: return "Chunk upload failed"
        case .verifyFileFail: return "Verify file failed."
        }
  }
}

struct EmptyRequestBody: Encodable {
    
}

struct Resources<T: Decodable, P: Encodable> {
    let path: String
    let requestType: RequestType
    let bodyParameters: P?
    let httpHeaderFields: [String : String]?
    var queryParameters: [String : Codable]?
}

class NetworkService {
    
    public func performRequest<T: Decodable, P: Encodable>(resources: Resources<T, P>) -> AnyPublisher<T, Error> {

        guard let url = getUrl(path: resources.path, queryParameters: resources.queryParameters) else {
            return Fail<T, Error>(error: NetworkError.badURL)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
//        print("REQUEST URL: ", url)
        var request = URLRequest(url: url)

        if let bodyParameters = resources.bodyParameters {
            let jsonData = try? JSONEncoder().encode(bodyParameters)
            request.httpBody = jsonData
        }

        if let headerFields = resources.httpHeaderFields {
            request.allHTTPHeaderFields = headerFields
        }
        
        request.httpMethod = resources.requestType.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("ios", forHTTPHeaderField: "os-name")
        request.addValue(UIDevice.current.systemVersion, forHTTPHeaderField: "os-version")
        request.addValue(UIDevice.current.model, forHTTPHeaderField: "device-name")
        request.addValue(UIDevice.current.identifierForVendor?.uuidString ?? "unknown", forHTTPHeaderField: "device-id")
        request.addValue((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "unknown", forHTTPHeaderField: "app-version")
        request.addValue(Locale.current.languageCode ?? "unknown", forHTTPHeaderField: "language")
        
//        return URLSession.shared.dataTaskPublisher(for: request)
//                    .map(\.data)
//                    .decode(type: T.self, decoder: JSONDecoder())
//                    .receive(on: DispatchQueue.main)
//                    .eraseToAnyPublisher()
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map({ (data, response) in
//                DebugUtils.printRequestAndResponse(request: request, data: data)
                let statusCode = (response as? HTTPURLResponse)?.statusCode
                switch statusCode {
                case 200:
                    break
//                    print("STATUS CODE 200")
                case 401:
                    break // TODO: - sign out
                case 404:
                    break
//                    print("STATUS CODE 404: ", response.url)
                default:
                    break
//                    print("STATUS CODE ", statusCode, "for url: ", request.url)
                }
                return data
            })
                    .decode(type: T.self, decoder: JSONDecoder())
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
    }
    
    private func getUrl(path: String, queryParameters: [String : Codable]?) -> URL? {
        let pathWithQueryParameters = addQueryParametersToPath(path: path, queryParameters: queryParameters)
        
        guard let url = URL(string: Constants.Networking.baseUrl + pathWithQueryParameters) else {
            return nil
        }
        return url
    }
    
    private func addQueryParametersToPath(path: String, queryParameters: [String : Codable]?) -> String {
        var newPath = path
        if let queryParameters = queryParameters {
            newPath.append("?")
            queryParameters.forEach { (key, value) in
                newPath = "\(newPath)\(key)=\(value)&"
            }
            newPath.removeLast()
        }
        return newPath
    }
    
}

