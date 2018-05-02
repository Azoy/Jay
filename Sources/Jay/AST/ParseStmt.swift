//
//  ParseStmt.swift
//  Jay
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

extension Parser {
  func parseReturnStmt() -> ReturnStmt {
    consumeTok()
    
    guard let expr = parseExpr() else {
      diagnose(ParseError.unableToParse(for: "expression"))
    }
    
    return ReturnStmt(value: expr)
  }
  
  func parseStmt() -> Stmt {
    guard let tok = currentTok else {
      diagnose(ParseError.unexpectedEOF("statement"))
    }
    
    guard case let .stmt(stmt) = tok else {
      diagnose(ParseError.unexpectedTokenMismatch("statement", with: tok))
    }
    
    switch stmt {
    case .return:
      return parseReturnStmt()
    default:
      diagnose(ParseError.unableToParse(for: "statement"))
    }
  }
}
