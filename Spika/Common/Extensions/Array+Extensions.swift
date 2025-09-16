//
//  Array+Extensions.swift
//  Spika
//
//  Created by Vedran Vugrin on 26.05.2023..
//

import Foundation

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

extension Array where Element: Hashable {
    // insert in array if item is not in array, if it is already then delete it
    mutating func toggle(_ el: Element) {
        if contains(el) {
            guard let index = firstIndex(where: { $0 == el })
            else { return }
            remove(at: index)
        } else {
            insert(el, at: 0)
        }
    }
    
    mutating func removeFirstIfExist(_ el: Element) {
        guard let index = firstIndex(where: { $0 == el }) else { return }
        remove(at: index)
    }
}
