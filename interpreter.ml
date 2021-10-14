open Ast

let env = Hashtbl.create 257

let rec lambda_of_expr expr =
  match expr with
  | Variable v -> Var v
  | Identifier id -> Hashtbl.find env id |> lambda_of_expr
  | Abstraction { param; body } ->
      let body = lambda_of_expr body in
      Abs { param; body }
  | Application { term; argum } ->
      let term = lambda_of_expr term in
      let argum = lambda_of_expr argum in
      App { term; argum }

let eval formatter library program =
  let rec eval_stmt stmt =
    match stmt with
    | Unit -> ()
    | Atribution { ident; value } -> Hashtbl.replace env ident value
    | Include f ->
        let lib =
          try
            f
            |> open_in
            |> Lexing.from_channel ~with_positions:false
            |> Parser.parse Lexer.token
          with _ -> Unit
        in
        eval_stmt lib
    | Sequence { s1; s2 } ->
        eval_stmt s1;
        eval_stmt s2
    | Term expr ->
        if !Commandline.interactive then print_string "β > ";
        Lambda.eval (lambda_of_expr expr) |> Printer.print_lambda formatter
  in
  eval_stmt library;
  eval_stmt program

let parse_commands input =
  match input with
  | "quit" | "exit" ->
      let _ = Sys.command "clear" in
      exit 0
  | "clean" | "clear" ->
      let _ = Sys.command "clear" in
      ()
  | "?" | "help" ->
      print_endline
        "Commands:\n\n\
         env:\t\tprints interpreter environment\n\n\
         ?\n\
         | help:\t\tprints this message\n\n\
         clear\n\
         | clean:\tclears the terminal\n\n\
         exit\n\
         | quit:\t\texits the interpreter"
  | "env" -> Printer.print_env Format.std_formatter env
  | _ -> (
      try
        let stmt = Lexing.from_string input |> Parser.parse Lexer.token in
        eval Format.std_formatter Unit stmt
      with
      | Not_found -> print_endline "Undefined term"
      | _ -> print_endline "Sintax error")

let run library program =
  eval Format.std_formatter library program;
  let _ = Sys.command "clear" in
  print_endline "Lambda Calculus Interpreter\n";
  try
    while true do
      print_string "λ > ";
      parse_commands (read_line ())
    done
  with _ ->
    let _ = Sys.command "clear" in
    exit 0
