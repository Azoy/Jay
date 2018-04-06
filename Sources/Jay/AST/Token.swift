//
//  Token.swift
//  Jay
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

/// Represents a char or group of chars in the source code
enum Token {
  /// (
  case lparen
  
  /// )
  case rparen
  
  /// {
  case lbrack
  
  /// }
  case rbrack
  
  /// ,
  case comma
  
  /// *
  case asterik
  
  /// =
  case equal
  
  /// Declarations such as struct
  case decl(Decl)
  
  /// Expressions like true, false
  case expr(Expr)
  
  /// Keywords like i32, if, else
  case kw(KW)
  
  /// Identifier
  case identifier(String)
  
  /// Integer literal
  case integerLiteral(String)
  
  /// String literal
  case stringLiteral(String)
}

extension Token {
  /// Declaration
  enum Decl: String {
    /// Structure value type
    case `struct`
  }
  
  /// Expression
  enum Expr: String {
    /// 00000001
    case `true`
    
    /// 00000000
    case `false`
  }
  
  /// Keyword
  enum KW: String {
    /// 8 bit integer
    case i8
    
    /// 16 bit integer
    case i16
    
    /// 32 bit integer
    case i32
    
    /// 64 bit integer
    case i64
    
    /// if statement
    case `if`
    
    /// else statement
    case `else`
    
    /// return statement
    case `return`
  }
}
