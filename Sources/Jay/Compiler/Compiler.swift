//
//  Compiler.swift
//  Jay
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

import Foundation
import LLVM

class Compiler {
  var arguments: [String] {
    return CommandLine.arguments
  }
  
  func compile() {
    guard arguments.contains("-i") else {
      print("Could not find input file, try marking it with '-i'")
      return
    }
    
    guard let inputIndex = arguments.index(of: "-i")?.advanced(by: 1) else {
      print("Could not find file name after '-i'")
      return
    }
    
    let sourceFile = arguments[inputIndex]
    let fileDataMaybe = FileManager.default.contents(
      atPath: FileManager.default.currentDirectoryPath + "/" + sourceFile
    )
    
    guard let fileData = fileDataMaybe else {
      print("Could not read file data from: \(sourceFile)")
      return
    }
    
    guard let source = String(data: fileData, encoding: .utf8) else {
      print("Could not decode file data from utf8")
      return
    }
    
    let lexer = Lexer(source: source)
    let tokens = lexer.performLex()
    
    if arguments.contains("-emit-lex") {
      for token in tokens {
        print(token)
      }
      
      return
    }
    
    let parser = Parser(tokens: tokens)
    let file = parser.performParse()
    
    if arguments.contains("-emit-parse") {
      for (_, function) in file.functions {
        print(function)
      }
      
      return
    }
    
    let typeChecker = TypeChecker(file: file)
    typeChecker.performSema()
    
    if arguments.contains("-emit-sema") {
      for (_, function) in file.functions {
        print(function)
      }
      
      return
    }
    
    let irGen = IRGen(
      file: file,
      moduleName: sourceFile.components(separatedBy: ".").first!
    )
    let module = irGen.performIRGen()
    
    if arguments.contains("-emit-ir") {
      module.dump()
      return
    }
    
    do {
      try module.verify()
      let target = try TargetMachine()
      let current = FileManager.default.currentDirectoryPath
      try target.emitToFile(
        module: module,
        type: .assembly,
        path: "\(current)/\(sourceFile.components(separatedBy: ".").first!)asm.txt"
      )
      try target.emitToFile(
        module: module,
        type: .object,
        path: "\(current)/\(sourceFile.components(separatedBy: ".").first!).o"
      )
    } catch {
      print(error.localizedDescription)
    }
  }
}
