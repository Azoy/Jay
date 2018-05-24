//
//  TypeCheckDecl.swift
//  Jay
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

extension TypeChecker {
  func typeCheckDecl(_ decl: inout Decl) {
    if var variable = decl as? Variable {
      typeCheckVariable(&variable)
      decl = variable
      return
    }
  }
  
  func typeCheckFunc(_ function: inout Function) {
    for i in function.params.indices {
      if function.params[i].type == "..." {
        if i != function.params.indices.upperBound {
          diagnose("Variadic type used before last parameter")
        }
      }
    }
    
    for i in function.body.indices {
      let line = function.body[i]
      
      if var decl = line as? Decl {
        typeCheckDecl(&decl)
        function.body[i] = decl
        continue
      }
      
      if var declRef = line as? DeclRefExpr {
        typeCheckDeclRef(&declRef)
        function.body[i] = declRef
        continue
      }
      
      if var returnStmt = line as? ReturnStmt {
        if !function.type.isEmpty {
          guard var expr = returnStmt.expr else {
            diagnose("Missing return expression for function: \(function.name)")
          }
          
          typeCheckExpr(&expr, decl: function)
          returnStmt.expr = expr
        }
        
        continue
      }
      
      diagnose("Unexpected value in function body")
    }
  }
  
  func typeCheckVariable(_ variable: inout Variable) {
    guard var expr = variable.expr else {
      diagnose("Unintialized variable found during type checking")
    }
    
    typeCheckExpr(&expr, decl: variable)
    variable.expr = expr
    
    scopeVars[variable.name] = variable
  }
}
