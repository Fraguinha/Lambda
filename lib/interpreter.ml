let env = Hashtbl.create 257

let rec string_of_lambda lambda =
  match lambda with
  | Ast.Var v -> v
  | Ast.Abs { param; body } -> "λ" ^ param ^ "." ^ string_of_lambda body
  | Ast.App { term; argum } ->
    "(" ^ string_of_lambda term ^ " " ^ string_of_lambda argum ^ ")"
;;

let rec lambda_of_expr expr =
  match expr with
  | Ast.Variable v -> Ast.Var v
  | Ast.Identifier id -> Hashtbl.find env id |> lambda_of_expr
  | Ast.Abstraction { param; body } ->
    let body = lambda_of_expr body in
    Ast.Abs { param; body }
  | Ast.Application { term; argum } ->
    let term = lambda_of_expr term in
    let argum = lambda_of_expr argum in
    Ast.App { term; argum }
;;

let is_unit stmt =
  match stmt with
  | Ast.Unit -> true
  | _ -> false
;;

let parse_file file =
  try
    file
    |> open_in
    |> Lexing.from_channel ~with_positions:true
    |> Parser.parse Lexer.token
  with
  | _ -> Ast.Unit
;;

let parse_string string =
  string |> Lexing.from_string ~with_positions:true |> Parser.parse Lexer.token
;;

let parse_stmt input =
  let stmt = parse_string input in
  let rec eval_stmt stmt =
    match stmt with
    | Ast.Unit -> None
    | Ast.Atribution { ident; value } ->
      Hashtbl.replace env ident value;
      None
    | Ast.Include f ->
      let lib =
        try
          f
          |> open_in
          |> Lexing.from_channel ~with_positions:false
          |> Parser.parse Lexer.token
        with
        | _ -> Ast.Unit
      in
      eval_stmt lib
    | Ast.Sequence { s1; s2 } ->
      let _ = eval_stmt s1 in
      eval_stmt s2
    | Ast.Term expr -> Some (Lambda.eval @@ lambda_of_expr expr)
  in
  eval_stmt stmt
;;

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
  | _ ->
    (match parse_stmt input with
     | None -> ()
     | Some lambda -> Printer.print_lambda Format.std_formatter lambda)
;;

let echo formatter stmt = Printer.print_stmt formatter stmt

let eval formatter library program =
  let rec eval_stmt stmt =
    match stmt with
    | Ast.Unit -> ()
    | Ast.Atribution { ident; value } -> Hashtbl.replace env ident value
    | Ast.Include f ->
      let lib =
        try
          f
          |> open_in
          |> Lexing.from_channel ~with_positions:false
          |> Parser.parse Lexer.token
        with
        | _ -> Ast.Unit
      in
      eval_stmt lib
    | Ast.Sequence { s1; s2 } ->
      eval_stmt s1;
      eval_stmt s2
    | Ast.Term expr ->
      Lambda.eval @@ lambda_of_expr expr |> Printer.print_lambda formatter
  in
  eval_stmt library;
  eval_stmt program
;;

let run_interactive library program =
  eval Format.std_formatter library program;
  let _ = Sys.command "clear" in
  print_endline "Lambda Calculus Interpreter\n";
  try
    while true do
      print_string "λ > ";
      parse_commands (read_line ())
    done
  with
  | _ ->
    let _ = Sys.command "clear" in
    exit 0
;;
