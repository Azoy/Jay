// swift-tools-version:4.0

import PackageDescription

let package = Package(
  name: "Jay",
  dependencies: [
    .package(url: "https://github.com/llvm-swift/LLVMSwift.git", from: "0.3.0")
  ],
  targets: [
    .target(
      name: "Jay",
      dependencies: ["LLVM"]
    )
  ]
)

