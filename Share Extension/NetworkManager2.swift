//
//  NetworkManager2.swift
//  Share Extension
//
//  Created by Nikola Barbarić on 23.08.2024..
//

import Foundation
import UIKit

class NetworkManager2 {
    internal func performRequest<req: Encodable, resp: Decodable>(resources: Resources<req>) async -> resp? {
        guard let url = resources.getUrl()
        else {
            print("DEBUGPRINT: PERFORM REQUEST, URL NOT VALID. URL: ", resources.getUrl() ?? "")
            return nil
        }
        
        guard let accessToken = getAccessToken()
        else {
            print("DEBUGPRINT: NO ACCESS TOKEN")
            return nil
        }
        
        var request = URLRequest(url: url)
        
        if let bodyParameters = resources.bodyParameters {
            let jsonData = try? JSONEncoder().encode(bodyParameters)
            request.httpBody = jsonData
        }
        
        if let headerFields = resources.httpHeaderFields {
            request.allHTTPHeaderFields = headerFields
        }
        
        request.httpMethod = resources.requestType.rawValue
        request.addValue(accessToken, forHTTPHeaderField: "accessToken")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("ios", forHTTPHeaderField: "os-name")
        request.addValue("shareExtension", forHTTPHeaderField: "requestSource")
        await request.addValue(UIDevice.current.systemVersion, forHTTPHeaderField: "os-version")
        await request.addValue(UIDevice.current.model, forHTTPHeaderField: "device-name")
        request.addValue((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "unknown", forHTTPHeaderField: "app-version")
        request.addValue(Locale.current.language.languageCode?.identifier ?? "unknown", forHTTPHeaderField: "language")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            DebugUtils.printRequestAndResponse(request: request, data: data)
            return try JSONDecoder().decode(resp.self, from: data)
        } catch {
            return nil
        }
    }
    
    func getAccessToken() -> String? {
        return UserDefaults(suiteName: Constants.Networking.appGroupName)!.string(forKey: Constants.Database.accessToken)
    }
}

