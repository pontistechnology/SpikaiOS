//
//  DebugUtils.swift
//  Spika
//
//  Created by Nikola Barbarić on 17.11.2022..
//

import Foundation
import SwiftUI

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

struct PreviewContainer<T: UIView>: UIViewRepresentable {
    let view: T
    init(_ viewBuilder: @escaping () -> T) {

        view = viewBuilder()
    }
    
    // MARK: - UIViewRepresentable
    func makeUIView(context: Context) -> T {
        return view
    }

    func updateUIView(_ view: T, context: Context) {}
}
