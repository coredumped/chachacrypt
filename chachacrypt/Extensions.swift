//
//  Extensions.swift
//  chachacrypt
//
//  Created by Juan Guerrero on 4/27/20.
//  Copyright © 2020 Juan Guerrero. All rights reserved.
//

import Foundation

extension FileHandle : TextOutputStream {
  public func write(_ string: String) {
    guard let data = string.data(using: .utf8) else { return }
    self.write(data)
  }
}
