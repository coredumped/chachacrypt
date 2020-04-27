//
//  main.swift
//  chachacrypt
//
//  Created by Juan Guerrero on 4/27/20.
//  Copyright © 2020 Juan Guerrero. All rights reserved.
//

import Foundation
import CryptoKit




func help() {
    let h =
"""

chachacrypt: A simple ChaCha20-Poly1305 encrypting/decrypting utility.

Arguments:
 -h                       Shows this help.
 -i <INPUT_FILE>          Path to a file to be processed.
 -o <OUTPUT_FILE>         Path to a file to be encrypted or decrypted. (Requires var, see below).
 -swift <OUTPUT_FILE>     Path to a swift source file to output the encrypted data. (Implies -e)
 -p <PASSWORD_STRING>     Password to use for encryption or decryption.
 -e                       Instructs the utility to encrypt the given input.
 -d                       Instructs the utility to decrypt the given input.
 -func                    Function name where the encrypted output can be referenced.
"""
    print(h)
    exit(0)
}

func encrypt(input: Data, key: SymmetricKey) throws -> Data {
    let box = try ChaChaPoly.seal(input, using: key)
    return box.combined
}

func decrypt(input: Data, key: SymmetricKey) throws -> Data {
    let box = try ChaChaPoly.SealedBox(combined: input)
    return try ChaChaPoly.open(box, using: key)
}


func parseCLI(_ cliArgs: [String]) -> CliArguments {
    var err = FileHandle.standardError
    var iter = cliArgs.makeIterator()
    var inputFile = ""
    var outputFile = ""
    var password = ""
    var operation: EncryptionOperation? = nil
    var swiftOn = false
    var function: String? = nil
    while let i = iter.next() {
        if i == "-i" {
            if let v = iter.next() {
                inputFile = v
            }
        }
        else if i == "-o" {
            if let v = iter.next() {
                outputFile = v
            }
        }
        else if i == "-swift" {
            if let v = iter.next() {
                outputFile = v
                swiftOn = true
                operation = .Encrypt
            }
        }
        else if i == "-p" {
            if let v = iter.next() {
                password = v
            }
        }
        else if i == "-h" || i == "--help" {
            help()
        }
        else if i == "-e" {
            operation = .Encrypt
        }
        else if i == "-d" {
            operation = .Decrypt
        }
        else if i == "-func" {
            if let f = iter.next() {
                function = f
            }
        }
    }
    //Validate
    if inputFile.isEmpty {
        print("Missing input file, specify one using the -i argument.", to: &err)
        exit(1)
    }
    if outputFile.isEmpty {
        print("Missing output file, specify one using the -o argument.", to: &err)
        exit(1)
    }
    if password.isEmpty {
        print("Can't encrypt/decrypt with no password given, please specify one with the -p argument.", to: &err)
        exit(1)
    }
    if operation == nil {
        print("Please specify what you want to do with \(inputFile), encrypt (-e) or decrypt (-d)?", to: &err)
        exit(1)
    }
    if swiftOn && function == nil {
        print("You specified -swift but forgot to specify -func.", to: &err)
        exit(1)
    }
    return CliArguments(inputFile: inputFile, outputFile: outputFile, password: password, operation: operation!, swift: swiftOn, function: function)
}

func generateSwiftSourceCode(_ data: Data, cmd: CliArguments) {
    let fout = cmd.outputFile.components(separatedBy: "/").last!
    let fin = cmd.inputFile.components(separatedBy: "/").last!
    let header =
"""
//
//  [OutputFile]
//
//  Encrypted from: [InputFile]
//
//  Created by chachacrypt.
//

import Foundation

func [function] () -> Data {
    return Data(base64Encoded:
""".replacingOccurrences(of: "[OutputFile]", with: fout)
    .replacingOccurrences(of: "[InputFile]", with: fin)
    .replacingOccurrences(of: "[function]", with: cmd.function!)

    let footer =
"""
)!
}

"""
    var output = Data()
    output.append(header.data(using: .utf8)!)
    output.append("\"".data(using: .utf8)!)
    output.append(data.base64EncodedString().data(using: .utf8)!)
    output.append("\"".data(using: .utf8)!)
    output.append(footer.data(using: .utf8)!)
    output.append("\n".data(using: .utf8)!)
    FileManager.default.createFile(atPath: cmd.outputFile, contents: output, attributes: nil)
}

func main(_ args: CliArguments) {
    var err = FileHandle.standardError
    do {
        let inputData = try Data(contentsOf: URL(fileURLWithPath: args.inputFile))
        var s = SHA256()
        s.update(data: args.password.data(using: .utf8)!)
        let key = SymmetricKey(data: s.finalize())
        var output: Data?
        if args.operation == .Encrypt {
            //Read input file into data
            output = try encrypt(input: inputData, key: key)
        }
        else {
            output = try decrypt(input: inputData, key: key)
        }
        if let o = output {
            if args.swift {
                generateSwiftSourceCode(o, cmd: args)
            }
            else {
                try o.write(to: URL(fileURLWithPath: args.outputFile))
            }
        }
    }
    catch let error {
        print("Unable to process files: \(error.localizedDescription)", to: &err)
        exit(1)
    }
}

let args = parseCLI(CommandLine.arguments)
main(args)
