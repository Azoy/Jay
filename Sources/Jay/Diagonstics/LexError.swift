//
//  LexError.swift
//  Jay
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

/// Represents issues that can occur when lexer has an issue
enum LexError {
  /// Represents a value that wasn't allowed in the various integer literals
  static func illegalChar(_ char: String, inIntegerLiteral radix: String) -> String {
    return "Illegal character: \(char) in \(radix) literal"
  }
  
  /// Represents a missing ascii value that was being expected
  static func missingClosing(_ char: String) -> String {
    return "Missing \(char) in code."
  }
  
  /// Represents an unknown character during lexical analysis
  static func unknownChar(_ char: String) -> String {
    return "Reached unexpected character: \(char)"
  }
}
