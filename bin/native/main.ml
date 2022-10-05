let () =
  Arg.parse Commandline.options Commandline.argument Commandline.usage;
  let program = Interpreter.parse_file !Commandline.input in
  let library = Interpreter.parse_file !Commandline.library in
  if (not !Commandline.interactive) && Interpreter.is_unit program
  then (
    Arg.usage Commandline.options Commandline.usage;
    exit 0);
  if !Commandline.interactive
  then Interpreter.run_interactive library program
  else (
    let formatter =
      try !Commandline.output |> open_out |> Format.formatter_of_out_channel with
      | _ -> Format.std_formatter
    in
    if !Commandline.parse_only
    then (
      Interpreter.echo formatter program;
      exit 0)
    else (
      try Interpreter.eval formatter library program with
      | _ -> ()))
;;
