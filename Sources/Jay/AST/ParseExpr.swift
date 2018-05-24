//
//  ParseExpr.swift
//  Jay
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

extension Parser {
  func parseDeclRef() -> DeclRefExpr {
    let name = parseIdentifier()
    let args = parseArgs()
    
    return DeclRefExpr(arguments: args, isFunctionCall: true, name: name, type: nil)
  }
  
  func parseExpr() -> Expr? {
    guard let tok = currentTok else {
      diagnose(ParseError.unexpectedEOF("expression"))
    }
    
    switch tok {
    case let .integerLiteral(num, radix):
      consumeTok()
      return IntegerExpr(radix: radix, type: nil, value: num)
      
    case let .stringLiteral(string):
      consumeTok()
      return StringExpr(type: "i8*", value: string)
      
    case .plus:
      consumeTok()
      return BinaryOperatorExpr(precedence: 1 << 0, type: nil, value: "+")
      
    case .minus:
      consumeTok()
      return BinaryOperatorExpr(precedence: 1 << 0, type: nil, value: "-")
      
    case .asterik:
      consumeTok()
      return BinaryOperatorExpr(precedence: 1 << 1, type: nil, value: "*")
      
    case .divide:
      consumeTok()
      return BinaryOperatorExpr(precedence: 1 << 1, type: nil, value: "/")
      
    case let .identifier(name):
      consumeTok()
      if let tok = currentTok, tok == .lparen {
        let args = parseArgs()
        return DeclRefExpr(
          arguments: args,
          isFunctionCall: true,
          name: name,
          type: nil
        )
      }
      
      return DeclRefExpr(
        arguments: [],
        isFunctionCall: false,
        name: name,
        type: nil
      )
    default:
      return nil
    }
  }
  
  func parseSeqExpr() -> SequenceExpr {
    var seqExpr = SequenceExpr(expressions: [], type: nil)
    while true {
      if !seqExpr.expressions.isEmpty {
        let last = seqExpr.expressions.last!
        if !(last is BinaryOperatorExpr), case .identifier(_) = currentTok! {
          break
        }
      }
      
      guard let expr = parseExpr() else {
        break
      }
      
      seqExpr.expressions.append(expr)
    }
    
    return seqExpr
  }
  
  func tryParseSeqExpr() -> Expr {
    guard let expr = parseExpr() else {
      diagnose("Could not find expression")
    }
    
    if let _ = parseExpr() {
      index -= 2
      return parseSeqExpr()
    }
    
    return expr
  }
}
