//
//  IRGen.swift
//  Jay
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

import LLVM

class IRGen : Diagnoser {
  var builder: IRBuilder
  let file: File
  var functions = [String: IRValue]()
  let module: Module
  var strings = [String: IRValue]()
  var scopeVars = [String: IRValue]()
  
  init(file: File, moduleName: String) {
    self.file = file
    self.module = Module(name: moduleName)
    self.builder = IRBuilder(module: self.module)
  }
  
  func allocateVar(_ variable: Variable) {
    let type = getKnownLLVMType(for: variable.type)
    scopeVars[variable.name] = builder.buildAlloca(type: type)
  }
  
  func getKnownLLVMType(for type: String) -> IRType {
    guard !type.contains("*") else {
      return getPointerType(for: type)
    }
    
    switch type {
    case "f16":
      return FloatType.half
    case "f32":
      return FloatType.float
    case "f64":
      return FloatType.double
    case "i1":
      return IntType.int1
    case "i8":
      return IntType.int8
    case "i16":
      return IntType.int16
    case "i32":
      return IntType.int32
    case "i64":
      return IntType.int64
    case "void":
      return VoidType()
    default:
      diagnose("Could not get ir type for type")
    }
  }
  
  func getPointerType(for type: String) -> PointerType {
    var baseTypeStr = ""
    var ptrCount = 0
    
    for c in type {
      guard c != "*" else {
        ptrCount += 1
        continue
      }
      
      baseTypeStr.append(c)
    }
    
    let baseType = getKnownLLVMType(for: baseTypeStr)
    var ptrType = PointerType(pointee: baseType)
    
    for _ in 1 ..< ptrCount {
      ptrType = PointerType(pointee: ptrType)
    }
    
    return ptrType
  }
  
  func handleDeclRef(_ declRef: DeclRefExpr) -> IRValue {
    guard declRef.isFunctionCall else {
      let ptr = scopeVars[declRef.name]!
      return builder.buildLoad(ptr)
    }
    
    let functionDecl: FunctionDecl
    
    if let function = file.functions[declRef.name] {
      functionDecl = function
    } else {
      functionDecl = file.foreignFunctions[declRef.name]!
    }
    
    var args = [IRValue]()
    for i in declRef.arguments.indices {
      let arg = declRef.arguments[i]
      var paramType: IRType? = nil
      
      if i < functionDecl.params.count, functionDecl.params[i].type != "..." {
        paramType = getKnownLLVMType(for: functionDecl.params[i].type)
      }
      
      var value = handleExpr(arg, type: paramType)
      
      if arg is StringExpr {
        value = builder.buildInBoundsGEP(
          value,
          indices: [
            0,
            0
          ]
        )
      }
      
      args.append(value)
    }
    
    let function = functions[declRef.name]!
    let call = builder.buildCall(
      function,
      args: args
    )
    
    return call
  }
  
  func handleExpr(_ expr: Expr, type: IRType? = nil) -> IRValue {
    if let declRef = expr as? DeclRefExpr {
      return handleDeclRef(declRef)
    }
    
    if let integerExpr = expr as? IntegerExpr {
      let intType: IntType
      
      if let type = type as? IntType {
        intType = type
      } else {
        intType = IntType.int32
      }
      
      let constant = intType.constant(
        integerExpr.value,
        radix: integerExpr.radix
      )
      
      return constant
    }
    
    if let stringExpr = expr as? StringExpr {
      return builder.buildGlobalString(stringExpr.value)
    }
    
    diagnose("Unknown expression kind during IRGen")
  }
  
  func handleVar(_ variable: Variable) {
    if variable.value.count == 1 {
      let value = handleExpr(
        variable.value.first!,
        type: getKnownLLVMType(
          for: variable.type
        )
      )
      let _ = builder.buildStore(value, to: scopeVars[variable.name]!)
      return
    }
    
    var declRefs = [DeclRefExpr]()
    for expr in variable.value {
      if let declRef = expr as? DeclRefExpr {
        declRefs.append(declRef)
      }
    }
    
    var tmpStorage = [IRValue]()
    for declRef in declRefs {
      guard let ref = scopeVars[declRef.name] else {
        return
      }
      
      tmpStorage.append(loadPtr(ref))
    }
    
    guard tmpStorage.count % 2 == 0 else {
      return
    }
    
    for i in 0 ..< declRefs.count / 2 {
      let first = tmpStorage[i]
      let second = tmpStorage[i + 1]
      let tmp = builder.buildAdd(first, second)
      
      guard let tmpVar = scopeVars[variable.name] else {
        return
      }
      
      let _ = builder.buildStore(tmp, to: tmpVar)
    }
  }
  
  func loadPtr(_ ptr: IRValue) -> IRValue {
    guard ptr.isAAllocaInst else {
      fatalError("Load to unknown instruction")
    }
    
    return builder.buildLoad(ptr)
  }
  
  func makeReturn(for stmt: ReturnStmt, with type: IRType) {
    if let integerLiteral = stmt.value as? IntegerExpr,
       let intType = type as? IntType {
      let constant = intType.constant(
        integerLiteral.value,
        radix: integerLiteral.radix
      )
      builder.buildRet(constant)
      return
    }
    
    diagnose("Could not create return type with given expression.")
  }
  
  func performIRGen() -> Module {
    // Declare foreign funcs first
    for (name, parsedForeignFunc) in file.foreignFunctions {
      var parsedForeignFunc = parsedForeignFunc
      var isVarArg = false
      if !parsedForeignFunc.params.isEmpty,
          parsedForeignFunc.params.last!.type == "..." {
        parsedForeignFunc.params.removeLast()
        isVarArg = true
      }
      let argTypes = parsedForeignFunc.params.map {
        getKnownLLVMType(for: $0.type)
      }
      let returnType = getKnownLLVMType(for: parsedForeignFunc.type)
      
      functions[name] = builder.addFunction(
        name,
        type: FunctionType(
          argTypes: argTypes,
          returnType: returnType,
          isVarArg: isVarArg
        )
      )
    }
    
    // Define funcs second
    for (name, parsedFunction) in file.functions {
      let argTypes = parsedFunction.params.map {
        getKnownLLVMType(for: $0.type)
      }
      let returnType = getKnownLLVMType(for: parsedFunction.type)
      
      let function = builder.addFunction(
        name,
        type: FunctionType(
          argTypes: argTypes,
          returnType: returnType
        )
      )
      
      let entry = function.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)
      
      // Initial alloca
      for line in parsedFunction.body {
        if let variable = line as? Variable {
          allocateVar(variable)
        }
      }
      
      // Run through a second time
      for line in parsedFunction.body {
        if let returnStmt = line as? ReturnStmt {
          makeReturn(for: returnStmt, with: returnType)
        }
        
        if let variable = line as? Variable {
          handleVar(variable)
        }
        
        if let declRef = line as? DeclRefExpr {
          _ = handleDeclRef(declRef)
        }
        
      }
      
      scopeVars.removeAll()
    }
    
    return module
  }
  
}
