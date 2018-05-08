//
//  CharacterHelper.swift
//  Jay
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

/// Stores ascii value for given character
enum ASCII: UInt32 {
  case tab = 9
  case newLine = 10
  case space = 32
  case doubleQuote = 34
  case atSign = 64
  
  /// The textual representation of this ascii value
  var character: Character {
    return Character(Unicode.Scalar(rawValue)!)
  }
}

extension Character {
  /// Returns the ascii enum
  var ascii: ASCII? {
    return ASCII(rawValue: value)
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
  
  /// Whether or not this char is a new line or space
  var isWhitespace: Bool {
    return ascii == .newLine || ascii == .space || ascii == .tab
  }
  
  /// Returns the ascii value of the char
  var value: UInt32 {
    return unicodeScalars.first!.value
  }
}
