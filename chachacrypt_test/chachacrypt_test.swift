//
//  chachacrypt_test.swift
//  chachacrypt_test
//
//  Created by Juan Guerrero on 4/27/20.
//  Copyright © 2020 Juan Guerrero. All rights reserved.
//

import XCTest
import CryptoKit

class chachacrypt_test: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testEncryptDecrypt () {
        var s = SHA256()
        s.update(data: "secret".data(using: .utf8)!)
        let key = SymmetricKey(data: s.finalize())
        let input = "hello world".data(using: .utf8)!
        let enc = try! encrypt(input: input, key: key)
        let dec = try! decrypt(input: enc, key: key)
        assert(String(data: dec, encoding: .utf8) == "hello world")
    }
    
    func testArgsParse () {
        let cmd = parseCLI(["chachacrypt", "-o", "ofile", "-i", "ifile", "-e", "-p", "secret"])
        assert(cmd.inputFile == "ifile")
        assert(cmd.outputFile == "ofile")
        assert(cmd.password == "secret")
        assert(cmd.operation == .Encrypt)
    }
}
