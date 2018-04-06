//
//  CharacterHelper.swift
//  Jay
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

/// Stores ascii value for given character
enum ASCIITable: UInt32 {
  case newLine = 10
  case space = 32
  case doubleQuote = 34
}

extension Character {
  /// Returns the ascii value of the char
  var value: UInt32 {
    return self.unicodeScalars.first!.value
  }
  
  /// Whether or not this char is a new line or space
  var isWhitespace: Bool {
    return value == ASCIITable.newLine.rawValue
      || value == ASCIITable.space.rawValue
  }
  
  /// Whether or not this char is a number or a letter
  var isAlnum: Bool {
    return isNum || isLetter
  }
  
  /// Whether or not this char is a letter
  var isLetter: Bool {
    return ("A" ... "z").contains(self)
  }
  
  /// Whether or not this char is a number
  var isNum: Bool {
    return ("0" ... "9").contains(self)
  }
}
