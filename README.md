# Lambda

Lambda Calculus System

### Playground

An online playground is available in my personal website at [https://fraguinha.com/post/lambda/](https://fraguinha.com/post/lambda/)

### Syntax

`x` or `x'`

`λx.M` or `\x.M`

`M N`

where `M` and `N` are lambda terms

This interpreter supports sintatic sugar like:

`λxyz.M` instead of `λx.(λy.(λz.M))`

and

`M N O` instead of `((M N) O)`

Terms can be defined in this way:

`Y=λf.(λx.f(xx))(λx.f(xx))`

or

`S=λxyz.xz(yz);K=λxy.x;I=λx.x`

or even

`FIRST=λxy.x`

### Instalation

Make sure you have a working OCaml instalation. Then run in your terminal:

```sh
dune build
```

### Use

Run:

```sh
./native/main.exe --interactive [-L res/library.lambda]
```

or

```sh
./native/main.exe input.txt [-o output.txt] [-L res/library.lambda]
```

### Documentation

You can run `./native/main.exe --help` or type `help` in the interpreter to get help

### Tests

You can run the examples with:

```sh
dune runtest
```
