# diablo-ast

Diablo Tree-Walk Interpreter

## About

**diablo-ast** is a tree-walk interpreter created in Nim. It is based on the Java implementation of the Lox Programming Language from the book [Crafting Interpreters](https://craftinginterpreters.com/). It makes use of Nim's intrinsic garbage collector to automate memory mangement. Please note, this is a purely experimental repository for educational and research purposes. 

## Usage

Generate AST.

```sh
nim compile --run tools/generate_ast.nim src
```

## License

diablo-ast is available under the [Apache License 2.0](https://spdx.org/licenses/Apache-2.0.html).

