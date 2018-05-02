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
  let module: Module
  var tmpVars = [String: IRValue]()
  
  init(file: File, moduleName: String) {
    self.file = file
    self.module = Module(name: moduleName)
    self.builder = IRBuilder(module: self.module)
  }
  
  func allocateVar(_ variable: Variable) {
    let type = getKnownLLVMType(for: variable.type)
    tmpVars[variable.name] = builder.buildAlloca(type: type)
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
  
  func handleExpr(_ expr: Expr, variable: Variable) {
    if let declRef = expr as? DeclRefExpr {
      guard let ref = tmpVars[declRef.name] else {
        return
      }
      
      guard let tmp = tmpVars[variable.name] else {
        return
      }
      
      let tmp2 = builder.buildLoad(ref.constGEP(indices: []))
      let _ = builder.buildStore(tmp2, to: tmp)
      return
    }
    
    if let integerExpr = expr as? IntegerExpr,
       let intType = getKnownLLVMType(for: variable.type) as? IntType {
      let constant = intType.constant(
        integerExpr.value,
        radix: integerExpr.radix
      )
      
      guard let tmp = tmpVars[variable.name] else {
        return
      }
      
      let _ = builder.buildStore(constant, to: tmp.constGEP(indices: []))
      return
    }
  }
  
  func handleVar(_ variable: Variable) {
    if variable.value.count == 1 {
      handleExpr(variable.value.first!, variable: variable)
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
      guard let ref = tmpVars[declRef.name] else {
        return
      }
      
      tmpStorage.append(builder.buildLoad(ref.constGEP(indices: [])))
    }
    
    guard tmpStorage.count % 2 == 0 else {
      return
    }
    
    for i in 0 ..< declRefs.count / 2 {
      let first = tmpStorage[i]
      let second = tmpStorage[i + 1]
      let tmp = builder.buildAdd(first, second)
      
      guard let tmpVar = tmpVars[variable.name] else {
        return
      }
      
      let _ = builder.buildStore(tmp, to: tmpVar)
    }
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
        guard let variable = line as? Variable else {
          continue
        }
        
        allocateVar(variable)
      }
      
      // Run through a second time
      for line in parsedFunction.body {
        if let returnStmt = line as? ReturnStmt {
          makeReturn(for: returnStmt, with: returnType)
        }
        
        if let variable = line as? Variable {
          handleVar(variable)
        }
        
      }
      
      tmpVars.removeAll()
    }
    
    return module
  }
  
}
