let lexer = Lexer(
  source: """
    i32 main(i32 argc, i8** argv) {
      i8** hello = "hello blitz"
      return 0
    }
    """
)

let tokens = lexer.performLex()

for token in tokens {
  print(token)
}
