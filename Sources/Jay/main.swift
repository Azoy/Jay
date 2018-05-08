import Foundation
import LLVM

let lexer = Lexer(
  source: """
    @foreign i32 printf(i8*, ...)
    @foreign i32 random()
    @foreign void srandom(i32)
    @foreign i32 time(i32)

    i32 main(i32 argc, i8** argv) {
      srandom(time(0))
      i32 random = random()
      printf("Random Number: %i\n", random)
      return 0
    }
    """
)

let tokens = lexer.performLex()
//print(tokens)

let parser = Parser(toks: tokens)

let file = parser.performParse()

for foreignFunc in file.foreignFunctions {
  print(foreignFunc.value)
}

for function in file.functions {
  print(function.value)
}
}
