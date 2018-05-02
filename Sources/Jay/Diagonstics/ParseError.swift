//
//  ParseError.swift
//  Jay
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

/// Represents issues that can occur when parser has an issue
enum ParseError {
  /// Represents an error during parsing for an item
  static func unableToParse(for item: String) -> String {
    return "Unable to parse for expected \(item)."
  }
  
  static func unexpectedEOF(_ tok: String) -> String {
    return "Was expecting: \(tok), but instead reached the end of the file."
  }
  
  static func unexpectedToken(_ tok: Token) -> String {
    return "Reached an unexpected token, \(tok), during parsing."
  }
  
  static func unexpectedTokenMismatch(_ tok1: String, with tok2: Token) -> String {
    return "Was expecting: \(tok1), but instead ran into \(tok2)."
  }
}
