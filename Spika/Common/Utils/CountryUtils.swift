//
//  CountryUtils.swift
//  Spika
//
//  Created by Marko on 28.10.2021..
//

import Foundation
import UIKit

class CountryHelper {
    
    static let shared = CountryHelper()
    
    private init() {
        
    }
    
    private let countries: [Country] = {
        var countries = [Country]()
        let path = Bundle.main.path(forResource: "CountryCodes", ofType: "json")
        guard let jsonPath = path, let jsonData = try? Data(contentsOf: URL(fileURLWithPath: jsonPath)) else {
            return countries
        }
        if let jsonObjects = (try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)) as? Array<Any> {
            for jsonObject in jsonObjects {
                guard let countryObj = jsonObject as? Dictionary<String, Any> else {
                    continue
                }
                guard let name = countryObj["name"] as? String,
                      let code = countryObj["code"] as? String,
                      let phoneCode = countryObj["dial_code"] as? String else {
                    continue
                }
                let country = Country(name: name, code: code, phoneCode: phoneCode)
                countries.append(country)
            }
        }
        return countries
    }()
    
    func getCountries() -> [Country] {
        return countries
    }
    
    func getCountry(code: String?) -> Country? {
        guard let code = code else { return nil }
        return countries.first(where: { $0.code == code })
    }
    
}
