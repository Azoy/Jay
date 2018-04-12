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
  func diagnose(_ error: String) -> Never
}

extension Diagnoser {
  /// Returns useful diagnostics to the user regarding a failure
  ///
  /// - parameter error: Specific reason for failure
  /// - parameter info: Extra info to enhance diagnostics
  func diagnose(_ error: String) -> Never {
    fatalError(error)
  }
}
