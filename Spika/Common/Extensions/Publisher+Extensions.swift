//
//  Publisher+Extensions.swift
//  Spika
//
//  Created by Vedran Vugrin on 05.01.2023..
//

import Combine
import Foundation

extension Publisher {
    func withLatestFrom<Other:Publisher>(_ other: Other)
        -> AnyPublisher<(Self.Output, Other.Output), Failure>
        where Self.Failure == Other.Failure {
            self.map { value in (value:value, date:Date()) }
                .combineLatest(other)
                .removeDuplicates { $0.0.date == $1.0.date }
                .map { ($0.value, $1) }
                .eraseToAnyPublisher()
    }
}
