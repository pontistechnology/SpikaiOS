//
//  DebugUtils.swift
//  Spika
//
//  Created by Nikola Barbarić on 17.11.2022..
//

import Foundation

class DebugUtils {
    static func printRequestAndResponse(request: URLRequest, data: Data?) {
        print("\n\n ____________START____________________")
        print("REQUEST link: ", request)
        let httpBody = String(decoding: request.httpBody ?? Data(), as: UTF8.self)
        print("request http body: ", httpBody)
        let responseString = String(decoding: data ?? Data(), as: UTF8.self)
        print("RESPONSE: ", responseString)
        print("\n\n ____________END____________________")
    }
}
