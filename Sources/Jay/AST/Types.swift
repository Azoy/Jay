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
  var foreignFunctions = [String: ForeignFunction]()
  var functions = [String: Function]()
}

struct ForeignFunction: FunctionDecl {
  let name: String
  var params: [Param]
  let type: String
}

struct Function: FunctionDecl {
  var body: [Any]
  let name: String
  var params: [Param]
  let type: String
}

protocol FunctionDecl {
  var name: String { get }
  var params: [Param] { get set }
  var type: String { get }
}

struct IntegerExpr : Expr {
  let radix: Int
  var type: String?
  let value: String
}

struct Param {
  let name: String?
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
