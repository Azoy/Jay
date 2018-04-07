//
//  Diagnoser.swift
//  Jay
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

/// Simple handler which can diagnose issues during compile
protocol Diagnoser {
  /// Returns useful diagnostics to the user regarding a failure
  ///
  /// - parameter error: Specific reason for failure
  /// - parameter info: Extra info to enhance diagnostics
  func diagnose(_ error: String, with info: String...)
}

extension Diagnoser {
  /// Returns useful diagnostics to the user regarding a failure
  ///
  /// - parameter error: Specific reason for failure
  /// - parameter info: Extra info to enhance diagnostics
  func diagnose(_ error: String, with info: String...) {
    var tmpIndex = error.index(of: "$")
    var msg = error
    
    for info in info {
      print(msg)
      guard let index = tmpIndex else {
        break
      }
      
      msg.remove(at: index)
      msg.insert(contentsOf: info, at: index)
      tmpIndex = msg.index(of: "$")
    }
    
    fatalError(msg)
  }
}
