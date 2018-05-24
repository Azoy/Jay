//
//  TypeCheckExpr.swift
//  Jay
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

extension TypeChecker {
  func typeCheckDeclRef(_ declRef: inout DeclRefExpr) {
    if declRef.isFunctionCall {
      if let function = file.functions[declRef.name] {
        declRef.type = function.type
        return
      }
      
      diagnose("Reference to undeclared function: \(declRef.name)")
    } else {
      if let variable = scopeVars[declRef.name] {
        declRef.type = variable.type
        return
      }
    }
    
    diagnose("Reference to undeclared type: \(declRef.name)")
  }
  
  func typeCheckExpr(_ expr: inout Expr, decl: Decl? = nil) {
    if var binaryExpr = expr as? BinaryOperatorExpr {
      guard let decl = decl else {
        diagnose("Cannot type check integer literal with an empty decl")
      }
      
      binaryExpr.type = decl.type
      expr = binaryExpr
    }
    
    if var declRef = expr as? DeclRefExpr {
      typeCheckDeclRef(&declRef)
      expr = declRef
    }
    
    if var integerExpr = expr as? IntegerExpr {
      guard let decl = decl else {
        diagnose("Cannot type check integer literal with an empty decl")
      }
      
      integerExpr.type = decl.type
      expr = integerExpr
    }
    
    if var seqExpr = expr as? SequenceExpr {
      guard let decl = decl else {
        diagnose("Cannot type check sequence expression with an empty decl")
      }
      
      // Type check each expression underneath this sequence
      for i in seqExpr.expressions.indices {
        typeCheckExpr(&seqExpr.expressions[i], decl: decl)
      }
      
      var tmpType = ""
      for expr in seqExpr.expressions {
        guard let type = expr.type else {
          diagnose("Expression in sequence does not have type assigned")
        }
        
        if tmpType.isEmpty {
          tmpType = type
        }
        
        guard type == tmpType else {
          diagnose(
            "Expression in sequence has different type from sequence. Expected: \(tmpType), got: \(type)"
          )
        }
      }
      
      seqExpr.type = tmpType
      expr = seqExpr
      
      var numOfOperators = 0
      for expr in seqExpr.expressions {
        if expr is BinaryOperatorExpr {
          numOfOperators += 1
        }
      }
      
      guard numOfOperators > 1 else {
        guard decl.type == expr.type else {
          diagnose("Mismatch type during type checking decl: \(decl.name)")
        }
        
        return
      }
      
      var tmpOperators = [TempBinaryOperatorExpr]()
      var tmpOperators2 = [TempBinaryOperatorExpr]()
      for i in seqExpr.expressions.indices {
        let expr = seqExpr.expressions[i]
        guard let binaryExpr = expr as? BinaryOperatorExpr else {
          continue
        }
        
        tmpOperators.append(TempBinaryOperatorExpr(key: i, value: binaryExpr))
      }
      
      tmpOperators2 = tmpOperators

      tmpOperators.sort {
        $0.value.precedence > $1.value.precedence
      }
      
      tmpOperators.sort {
        if $0.value.precedence == $1.value.precedence {
          return $0.key < $1.key
        }
        
        return false
      }
      
      guard tmpOperators != tmpOperators2 else {
        guard decl.type == expr.type else {
          diagnose("Mismatch type during type checking decl: \(decl.name)")
        }
        
        return
      }
      
      var newSeqExpr = SequenceExpr(expressions: [], type: tmpType)
      for tmpBinaryExpr in tmpOperators {
        let index = tmpBinaryExpr.key
        let binaryExpr = tmpBinaryExpr.value
        guard index + 1 < seqExpr.expressions.count else {
          diagnose("Infix operator without rhs")
        }
        
        let lhs = seqExpr.expressions[index - 1]
        let rhs = seqExpr.expressions[index + 1]
        
        if let movedExpr = lhs as? MovedExpr {
          if let movedExpr2 = rhs as? MovedExpr {
            newSeqExpr.expressions.append(newSeqExpr.expressions[movedExpr2.index])
            newSeqExpr.expressions[movedExpr2.index] = binaryExpr
          } else {
            guard var tmpSeqExpr = newSeqExpr.expressions[movedExpr.index] as? SequenceExpr else {
              diagnose("Moved expression was not a sequence expression")
            }
            
            tmpSeqExpr.expressions += [binaryExpr, rhs]
            newSeqExpr.expressions[movedExpr.index] = tmpSeqExpr
          }
          
          continue
        }
        
        if let movedExpr = rhs as? MovedExpr {
          guard var tmpSeqExpr = newSeqExpr.expressions[movedExpr.index] as? SequenceExpr else {
            diagnose("Moved expression was not a sequence expression")
          }
          
          tmpSeqExpr.expressions += [binaryExpr, lhs]
          newSeqExpr.expressions[movedExpr.index] = tmpSeqExpr
          continue
        }
        
        newSeqExpr.expressions.append(
          SequenceExpr(
            expressions: [lhs, binaryExpr, rhs], type: tmpType
          )
        )
        
        let movedExpr = MovedExpr(
          index: newSeqExpr.expressions.count - 1,
          type: nil
        )
        
        seqExpr.expressions[index - 1] = movedExpr
        seqExpr.expressions[index + 1] = movedExpr
      }
      
      expr = newSeqExpr
    }
    
    guard let decl = decl else {
      return
    }
    
    guard decl.type == expr.type else {
      diagnose("Mismatch type during type checking decl: \(decl.name)")
    }
  }
}
