//
//  Model.swift
//  chachacrypt
//
//  Created by Juan Guerrero on 4/27/20.
//  Copyright © 2020 Juan Guerrero. All rights reserved.
//

import Foundation

enum EncryptionOperation {
    case Encrypt
    case Decrypt
}

struct CliArguments {
    var inputFile = ""
    var outputFile = ""
    var password = ""
    var operation: EncryptionOperation = .Encrypt
    var swift: Bool = false
    var function: String? = nil
}
