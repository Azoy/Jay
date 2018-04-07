//
//  Lexer.swift
//  Jay
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

/// Performs lexical analysis on given source code
class Lexer : Diagnoser {
  /// The given source to performLex on
  let source: String
  
  /// The current index for the source
  var index: String.Index
  
  /// Returns the current character if it is not the EOF
  var currentChar: Character? {
    return index < source.endIndex ? source[index] : nil
  }
  
  /// Initializes the Lexer with the given source
  ///
  /// - parameter source: The source code to lex
  init(source: String) {
    self.source = source
    self.index = source.startIndex
  }
  
  /// Tries to get a token for the current character (if we know it)
  func getKnownChar(_ char: Character) -> Token? {
    switch char {
    case "(":
      return .lparen
    case ")":
      return .rparen
    case "{":
      return .lbrack
    case "}":
      return .rbrack
    case ",":
      return .comma
    case "*":
      return .asterik
    case "=":
      return .equal
    default:
      return nil
    }
  }
  
  /// Checks if an alnum string is an integer literal
  ///
  /// - parameter str: The alnum string to check
  /// - return: The integer literal with the radix included if deemed an integer literal
  func isIntegerLiteral(_ str: String) -> (literal: String, radix: Int)? {
    var str = str
    
    // Handle binary literals
    if str.hasPrefix("0b") {
      str.removeFirst(2)
      
      for char in str {
        guard ("0" ... "1").contains(char) else {
          diagnose(
            LexError.illegalValueInIntegerLiteral.rawValue,
            with: "binary", char.description
          )
          return nil
        }
      }
      
      return (str, 2)
    }
    
    // Handle octal literals
    if str.hasPrefix("0o") {
      str.removeFirst(2)
      
      for char in str {
        guard ("0" ... "7").contains(char) else {
          diagnose(
            LexError.illegalValueInIntegerLiteral.rawValue,
            with: "octal", char.description
          )
          return nil
        }
      }
      
      return (str, 8)
    }
    
    // Handle hex literals
    if str.hasPrefix("0x") {
      str.removeFirst(2)
      
      for char in str {
        guard ("0" ... "9").contains(char)
          || ("A" ... "F").contains(char)
          || ("a" ... "f").contains(char) else {
          diagnose(
            LexError.illegalValueInIntegerLiteral.rawValue,
            with: "hex", char.description
          )
          return nil
        }
      }
      
      return (str, 16)
    }
    
    // Handle regular integer literals
    for char in str {
      guard char.isNum else {
        return nil
      }
    }
    
    return (str, 10)
  }
  
  /// Looks at the given source from index to end in search of the ascii
  ///
  /// - parameter ascii: ASCII value to make sure source has
  /// - return: Whether or not the source contains this ascii value
  func lookAhead(for ascii: ASCII) -> Bool {
    let tmpSource = source.suffix(from: index)
    let char = Character(Unicode.Scalar(ascii.rawValue)!)
    return tmpSource.contains(char)
  }
  
  /// Advances the current index to the next char
  func nextIndex() {
    source.formIndex(after: &index)
  }
  
  /// Produces the next token
  ///
  /// - return: Token of current index
  func nextToken() -> Token? {
    // Ignore whitespace
    while let char = currentChar, char.isWhitespace {
      nextIndex()
    }
    
    // Make sure not EOF
    guard let char = currentChar else {
      return nil
    }
    
    // If we know this char, return it
    if let tok = getKnownChar(char) {
      nextIndex()
      return tok
    }
    
    // Check if char is start of string literal
    if char.ascii == .doubleQuote {
      let stringLiteral = readUntilNext(.doubleQuote)
      return .stringLiteral(stringLiteral)
    }
    
    // Make sure the char is alnum from here on out
    guard char.isAlnum else {
      return nil
    }
    
    // Reads the source to provide the next alnum string
    let str = readAlnum()
    
    // If this alnum string is a decl, return it
    if let decl = Token.Decl(rawValue: str) {
      return .decl(decl)
    }
    
    // If this alnum string is a expr, return it
    if let expr = Token.Expr(rawValue: str) {
      return .expr(expr)
    }
    
    // If this alnum string is a kw, return it
    if let kw = Token.KW(rawValue: str) {
      return .kw(kw)
    }
    
    // If this alnum string is a stmt, return it
    if let stmt = Token.Stmt(rawValue: str) {
      return .stmt(stmt)
    }
    
    // Check if alnum string is an integer literal
    if let integer = isIntegerLiteral(str) {
      return .integerLiteral(integer.literal, integer.radix)
    }
    
    // Otherwise assume this is an identifier
    return .identifier(str)
  }
  
  /// Performs lexical analysis on the source code
  ///
  /// - return: Source code represented in an array of tokens
  func performLex() -> [Token] {
    var toks = [Token]()
    while let tok = nextToken() {
      toks.append(tok)
    }
    
    return toks
  }
  
  /// Reads the current and future chars to produce an alnum string
  ///
  /// - return: The alnum string
  func readAlnum() -> String {
    var str = ""
    while let char = currentChar, char.isAlnum {
      str.append(char)
      nextIndex()
    }
    
    return str
  }
  
  /// Reads the current and future chars to return everything inbetween
  ///
  /// - return: The string within the literal
  func readUntilNext(_ ascii: ASCII) -> String {
    // Remove first ascii value
    nextIndex()
    
    // Look ahead to make sure the source has another ascii unit
    guard lookAhead(for: ascii) else {
      diagnose(
        LexError.missingASCIIUntil.rawValue,
        with: ascii.character.description
      )
      return ""
    }
    
    // Get everything inbetween
    var str = ""
    while let char = currentChar, char.ascii != ascii {
      str.append(char)
      nextIndex()
    }
    
    // Remove final ascii value
    nextIndex()
    
    return str
  }
}
