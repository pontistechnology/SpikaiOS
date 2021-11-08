//
//  Assembler+Extensions.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import Foundation
import Swinject

extension Assembler {
    static let sharedAssembler: Assembler = {
        let container = Container()
        let assembler = Assembler([
            AppAssembly(),
            LoginAssembly(),
            TestAssembly()
        ], container: container)
        return assembler
    }()
}
