//
//  Types.swift
//  Jay
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

struct BinaryOperatorExpr : Expr, Equatable {
  let precedence: Int
  var type: String?
  let value: String
}

protocol Decl {
  var name: String { get }
  var type: String { get }
}

struct DeclRefExpr : Expr {
  let arguments: [Expr]
  let isFunctionCall: Bool
  let name: String
  var type: String?
}

protocol Expr {
  var type: String? { get set }
}

class File {
  var functions = [String: Function]()
}

struct Function: Decl {
  var body: [Any]
  
  var isForeignFunc: Bool {
    guard body.isEmpty else {
      return false
    }
    
    for param in params {
      guard param.name == nil else {
        return false
      }
    }
    
    return true
  }
  
  var isVarArg: Bool {
    guard let lastParam = params.last else {
      return false
    }
    
    return lastParam.type == "..."
  }
  
  let name: String
  var params: [Param]
  let type: String
}

struct IntegerExpr : Expr {
  let radix: Int
  var type: String?
  let value: String
}

struct MovedExpr: Expr {
  let index: Int
  var type: String?
}

struct Param {
  let name: String?
  let type: String
}

struct ReturnStmt : Stmt {
  var expr: Expr?
}

struct SequenceExpr: Expr {
  var expression: Expr {
    guard expressions.count > 0 else {
      fatalError("Sequence Expression had no expressions to return")
    }
    
    return expressions.count == 1 ? expressions.first! : self
  }
  
  var expressions: [Expr]
  var type: String?
}

protocol Stmt {}

struct StringExpr : Expr {
  var type: String?
  let value: String
}

struct TempBinaryOperatorExpr: Equatable {
  let key: Int
  let value: BinaryOperatorExpr
}

struct Variable: Decl {
  let name: String
  let type: String
  var expr: Expr?
}
