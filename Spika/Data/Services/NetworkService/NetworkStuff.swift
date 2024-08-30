//
//  NetworkStuff.swift
//  Spika
//
//  Created by Nikola Barbarić on 22.08.2024..
//

import Foundation

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

struct Resources<P: Encodable> {
    let path: String
    let requestType: RequestType
    let bodyParameters: P?
    var httpHeaderFields: [String : String]?
    var queryParameters: [String : Codable]?
    
    func getUrl() -> URL? {
        let pathWithQueryParameters = addQueryParametersToPath()
        
        guard let url = URL(string: Constants.Networking.baseUrl + pathWithQueryParameters) else {
            return nil
        }
        return url
    }
    
    private func addQueryParametersToPath() -> String {
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
