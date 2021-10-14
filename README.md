# Lambda
Lambda Calculus Interpreter/Compiler

# Instalation

Make sure you have a working OCaml instalation. Then run in your terminal:

```sh
dune build
```

# Use

Run:

```sh
./main.exe --interactive [-L lib/std.lambda]
```

or

```sh
./main.exe input.txt [-o output.txt] [-L lib/std.lambda]
```

# Syntax

`x` or `x'`

`λx.M` or `\x.M`

`M N`

where `M` and `N` are lambda terms

This interpreter supports sintatic sugar like:

`λxyz.M` instead of `λx.λy.λz.M`

Terms can be defined in this way:

`Y=\f.(\x.f(xx))(\x.f(xx))`

or

`S=λxyz.xz(yz);K=\xy.x;I=\x.x`

or even

`FIRST=\xy.x`

# Documentation

You can run `./main.exe --help` or type `help` in the interpreter to get help

# Tests

You can run tests with:

```sh
dune runtest
```
