import LLVM

let lexer = Lexer(
  source: """
    i32 main(i32 argc, i8** argv) {
      i32 x = 4
      i32 y = 12
      i32 z = x + y
      return 0
    }
    """
)

let tokens = lexer.performLex()

let parser = Parser(toks: tokens)

let file = parser.performParse()

for function in file.functions {
  print(function.value)
}
}
