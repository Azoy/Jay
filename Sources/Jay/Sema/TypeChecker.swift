//
//  TypeChecker.swift
//  Jay
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

class TypeChecker: Diagnoser {
  var file: File
  var scopeVars = [String: Variable]()
  
  init(file: File) {
    self.file = file
  }
  
  func performSema() {
    for (name, var function) in file.functions {
      guard !function.isForeignFunc else {
        continue
      }
      
      typeCheckFunc(&function)
      file.functions[name] = function
    }
  }
}
