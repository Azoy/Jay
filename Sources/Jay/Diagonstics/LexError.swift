//
//  LexError.swift
//  Jay
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

/// Represents issues that can occur when lexer has an issue
enum LexError: String {
  /// Represents a value that wasn't allowed in the various integer literals
  case illegalValueInIntegerLiteral = "Illegal character in $ literal: $"
  
  /// Represents a missing ascii value that was being expected
  case missingASCIIUntil = "Expected closing $"
}
