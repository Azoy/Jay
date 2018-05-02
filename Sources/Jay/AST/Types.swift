//
//  Types.swift
//  Jay
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

struct BinaryOperatorExpr : Expr {
  var type: String?
  let value: String
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

struct Function {
  var body: [Any]
  let name: String
  let params: [Param]
  let type: String
}

struct IntegerExpr : Expr {
  let radix: Int
  var type: String?
  let value: String
}

struct Param {
  let name: String
  let type: String
}

struct ReturnStmt : Stmt {
  let value: Expr
}

protocol Stmt {}

struct StringExpr : Expr {
  var type: String?
  let value: String
}

struct Variable {
  let name: String
  let type: String
  let value: [Expr]
}
