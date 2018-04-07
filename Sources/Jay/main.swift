let lexer = Lexer(
  source: """
    i32 main(i32 argc, i8** argv) {
      i16 x = 0b100
      i16 y = 0xC
      i16 z = x + y
      return 0
    }
    """
)

let tokens = lexer.performLex()

for token in tokens {
  print(token)
}
