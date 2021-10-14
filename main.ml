open Ast

let () =
  Arg.parse Commandline.options Commandline.argument Commandline.usage;
  let program =
    try
      !Commandline.input
      |> open_in
      |> Lexing.from_channel ~with_positions:true
      |> Parser.parse Lexer.token
    with _ -> Unit
  in
  let library =
    try
      !Commandline.library
      |> open_in
      |> Lexing.from_channel ~with_positions:true
      |> Parser.parse Lexer.token
    with _ -> Unit
  in
  if !Commandline.parse_only then exit 0;
  if program = Unit && not !Commandline.interactive then (
    Arg.usage Commandline.options Commandline.usage;
    exit 0);
  if !Commandline.pretty_print then (
    Printer.print_stmt Format.std_formatter program;
    exit 0);
  if !Commandline.interactive then Interpreter.run library program;
  let formatter =
    try !Commandline.output |> open_out |> Format.formatter_of_out_channel
    with _ -> Format.std_formatter
  in
  try Interpreter.eval formatter library program with _ -> ()
