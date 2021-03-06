//
//  Parser.swift
//  Jay
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

class Parser: Diagnoser {
  let file = File()
  var index = 0
  var scope: Function?
  let tokens: [Token]
  
  var currentTok: Token? {
    return index < tokens.count ? tokens[index] : nil
  }
  
  init(tokens: [Token]) {
    self.tokens = tokens
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
  
  func handleAttribute() {
    guard case let .attr(attr) = currentTok! else {
      diagnose("")
    }
    
    switch attr {
    case .foreign:
      let foreignFunc = parseForeignFunc()
      file.functions[foreignFunc.name] = foreignFunc
    }
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
      
      if let _ = parseExpr() {
        index -= 2
        args.append(parseSeqExpr())
        continue
      }
      
      args.append(expr)
    }
    
    consume(.rparen)
    return args
  }
  
  func parseForeignFunc() -> Function {
    consumeTok()
    let type = parseType()
    let name = parseIdentifier()
    let params = parseForeignParams()
    
    return Function(body: [], name: name, params: params, type: type)
  }
  
  func parseForeignParams() -> [Param] {
    consume(.lparen)
    var params = [Param]()
    while let tok = currentTok, tok != .rparen {
      if currentTok == .comma {
        consume(.comma)
      }
      
      // Try and consume a vararg
      guard currentTok != .period else {
        consume(.period)
        consume(.period)
        consume(.period)
        params.append(Param(name: nil, type: "..."))
        continue
      }
      
      if case .identifier(_) = currentTok! {
        params.append(Param(name: nil, type: parseIdentifier()))
        continue
      }
      
      if case .type(_) = currentTok! {
        params.append(Param(name: nil, type: parseType()))
        continue
      }
      
      diagnose("Did not receive a type during parsing foreign function parameter")
    }
    
    consume(.rparen)
    return params
  }
  
  func parseFunc() -> Function {
    let type = parseType()
    let name = parseIdentifier()
    let params = parseParams()
    
    consume(.lcurly)
    
    var body = [Any]()
    
    while let tok = currentTok, tok != .rcurly {
      switch tok {
      case .identifier(_):
        body.append(parseDeclRef())
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
    
    consume(.equal)
    
    return Variable(name: name, type: type, expr: tryParseSeqExpr())
  }
  
  func performParse() -> File {
    // Perform top level parsing
    while let tok = currentTok {
      switch tok {
      case .attr(_):
        handleAttribute()
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
