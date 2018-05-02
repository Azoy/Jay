//
//  Parser.swift
//  Jay
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

class Parser : Diagnoser {
  var index = 0
  var scope: Function?
  let toks: [Token]
  
  var currentTok: Token? {
    return index < toks.count ? toks[index] : nil
  }
  
  init(toks: [Token]) {
    self.toks = toks
  }
  
  func consumeTok() {
    index += 1
  }
  
  func consume(_ token: Token) {
    guard let tok = currentTok else {
      diagnose(ParseError.unexpectedEOF("\(token)"))
    }
    
    guard token == tok else {
      diagnose(ParseError.unexpectedTokenMismatch("\(token)", with: tok))
    }
    
    consumeTok()
  }
  
  func parseArgs() -> [Expr] {
    consume(.lparen)
    var args = [Expr]()
    while let tok = currentTok, tok != .rparen {
      if currentTok == .comma {
        consume(.comma)
      }
      
      guard let expr = parseExpr() else {
        diagnose(ParseError.unexpectedToken(tok))
      }
      
      args.append(expr)
    }
    
    consume(.rparen)
    return args
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
      return BinaryOperatorExpr(type: nil, value: "+")
      
    case .minus:
      consumeTok()
      return BinaryOperatorExpr(type: nil, value: "-")
      
    case .asterik:
      consumeTok()
      return BinaryOperatorExpr(type: nil, value: "*")
      
    case .divide:
      consumeTok()
      return BinaryOperatorExpr(type: nil, value: "/")
      
    case let .identifier(name):
      if let tok = currentTok, tok == .lparen {
        let args = parseArgs()
        consumeTok()
        return DeclRefExpr(
          arguments: args,
          isFunctionCall: true,
          name: name,
          type: nil
        )
      }
      
      consumeTok()
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
  
  func parseFunc() -> Function {
    let type = parseType()
    let name = parseIdentifier()
    let params = parseParams()
    
    consume(.lcurly)
    
    var body = [Any]()
    
    while let tok = currentTok, tok != .rcurly {
      switch tok {
      case .stmt(_):
        body.append(parseStmt())
      case .type(_):
        body.append(parseVar())
      default:
        diagnose(ParseError.unexpectedToken(tok))
      }
    }
    
    guard currentTok != nil else {
      diagnose(ParseError.unexpectedEOF("ending curly bracket"))
    }
    
    consume(.rcurly)
    
    let function = Function(body: body, name: name, params: params, type: type)
    self.scope = function
    
    return function
  }
  
  func parseIdentifier() -> String {
    guard let tok = currentTok else {
      diagnose(ParseError.unexpectedEOF("identifier"))
    }
    
    guard case let .identifier(name) = tok else {
      diagnose(ParseError.unexpectedTokenMismatch("identifier", with: tok))
    }
    
    consumeTok()
    return name
  }
  
  func parseParams() -> [Param] {
    consume(.lparen)
    var args = [Param]()
    while let tok = currentTok, tok != .rparen {
      let type = parseType()
      let name = parseIdentifier()
      if currentTok == .comma {
        consume(.comma)
      }
      
      args.append(Param(name: name, type: type))
    }
    
    consume(.rparen)
    return args
  }
  
  func parseType() -> String {
    guard let tok = currentTok else {
      diagnose(ParseError.unexpectedEOF("type"))
    }
    
    guard case let .type(name) = tok else {
      diagnose(ParseError.unexpectedTokenMismatch("type", with: tok))
    }
    
    consumeTok()
    
    var type = name.rawValue
    while currentTok == .asterik {
      consume(.asterik)
      type.append("*")
    }
    
    return type
  }
  
  func parseVar() -> Variable {
    let type = parseType()
    let name = parseIdentifier()
    var value = [Expr]()
    
    consume(.equal)
    
    guard currentTok != nil else {
      diagnose(ParseError.unexpectedEOF("variable value"))
    }
    
    while currentTok != nil, let expr = parseExpr() {
      value.append(expr)
    }
    
    return Variable(name: name, type: type, value: value)
  }
  
  func performParse() -> File {
    let file = File()
    while let tok = currentTok {
      switch tok {
      case .type(_): // Parse function declaration
        let function = parseFunc()
        file.functions[function.name] = function
      default:
        diagnose(ParseError.unexpectedToken(tok))
      }
    }
    
    return file
  }
  
}
