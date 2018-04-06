//
//  Lexer.swift
//  Jay
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

/// Performs lexical analysis on given source code
class Lexer {
  /// The given source to performLex on
  let source: String
  
  /// The current index for the source
  var index: String.Index
  
  /// Map of known direct conversions from character to token
  let knownChars: [Character: Token] = [
    "(": .lparen,
    ")": .rparen,
    "{": .lbrack,
    "}": .rbrack,
    ",": .comma,
    "*": .asterik,
    "=": .equal
  ]
  
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
  
  /// Checks if an alnum string is an integer literal
  ///
  /// - parameter str: The alnum string to check
  /// - return: Whether or not alnum string is an integer literal
  func isIntegerLiteral(_ str: String) -> Bool {
    for char in str {
      guard char.isNum else {
        return false
      }
    }
    
    return true
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
    if let tok = knownChars[char] {
      nextIndex()
      return tok
    }
    
    // Check if char is start of string literal
    if char.value == ASCIITable.doubleQuote.rawValue {
      let stringLiteral = readStringLiteral()
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
    
    // Check if alnum string is an integer literal
    if isIntegerLiteral(str) {
      return .integerLiteral(str)
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
  
  /// Reads the current and future chars to produce a string literal
  ///
  /// - return: The string within the literal
  func readStringLiteral() -> String {
    nextIndex()
    
    var str = ""
    while let char = currentChar,
          char.value != ASCIITable.doubleQuote.rawValue {
      str.append(char)
      nextIndex()
    }
    nextIndex()
    
    return str
  }
}
