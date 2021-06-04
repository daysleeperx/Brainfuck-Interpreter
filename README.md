# Brainfuck Interpreter

The project was built with Idris 2, version 0.3.0.

## Building and Running
Idris [package file](https://idris2.readthedocs.io/en/latest/reference/packages.html) is used in this project and will output `interpret` executable in the current project directory by running
```bash
idris2 --build brainfuck.ipkg
```
Running a program
```bash
echo "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++." > prog && ./interpret prog
```

## Included Examples
```bash
./interpret brainfuck/hello.bf        # Hello World!
./interpret brainfuck/fibonacci.bf    # Infinite Fibonacci sequence. Has to be terminated! :D
./interpret brainfuck/factorial.bf    # Infinite Factorial sequence. Has to be terminated! :D
./interpret brainfuck/reverse.bf      # Gets string from input and reverses it after pressing ENTER
```

## Issues
- The parser is stopping at the first unrecognised symbol, so if comments, spaces or other symbols are included in `.bf` file, the program will not run as expected
```haskell
parse parseCommands ",[]a."
[([Input, Loop []], "a.")]
```
