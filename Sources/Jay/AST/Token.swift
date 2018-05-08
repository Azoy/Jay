//
//  Token.swift
//  Jay
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

/// Represents a char or group of chars in the source code
enum Token: Equatable {
  /// (
  case lparen
  
  /// )
  case rparen
  
  /// {
  case lcurly
  
  /// }
  case rcurly
  
  /// [
  case lbracket
  
  /// ]
  case rbracket
  
  /// ,
  case comma
  
  /// *
  case asterik
  
  /// =
  case equal
  
  /// +
  case plus
  
  /// -
  case minus
  
  /// x
  case times
  
  /// /
  case divide
  
  /// %
  case mod
  
  /// .
  case period
  
  /// Attributes such as @foreign
  case attr(Attribute)
  
  /// Declarations such as struct
  case decl(Decl)
  
  /// Expressions like true, false
  case expr(Expr)
  
  /// Known Types like f32, i32, i64
  case type(KnownType)
  
  /// Statements like if, else, return
  case stmt(Stmt)
  
  /// Identifier (name)
  case identifier(String)
  
  /// Integer literal (number, radix)
  case integerLiteral(String, Int)
  
  /// String literal (string)
  case stringLiteral(String)
}

extension Token {
  /// Attributes
  enum Attribute: String {
    /// Foreign function
    case foreign
  }
  
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
  
  /// Known Types
  enum KnownType: String {
    /// 16 bit float
    case f16
    
    /// 32 bit float
    case f32
    
    /// 64 bit float
    case f64
    
    /// 8 bit integer
    case i8
    
    /// 16 bit integer
    case i16
    
    /// 32 bit integer
    case i32
    
    /// 64 bit integer
    case i64
    
    /// void
    case void
  }
  
  /// Statement
  enum Stmt: String {
    /// if statement
    case `if`
    
    /// else statement
    case `else`
    
    /// return statement
    case `return`
    
    /// for statement
    case `for`
    
    /// in statement
    case `in`
  }
}
