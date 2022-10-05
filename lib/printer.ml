open Ast

let print_lambda file lambda =
  let rec print_lambda_lambda' lambda =
    match lambda with
    | Var v -> Format.fprintf file "%s" v
    | Abs { param; body } ->
      Format.fprintf file "(";
      Format.fprintf file "λ%s" param;
      Format.fprintf file ".";
      print_lambda_lambda' body;
      Format.fprintf file ")"
    | App { term; argum } ->
      Format.fprintf file "(";
      print_lambda_lambda' term;
      print_lambda_lambda' argum;
      Format.fprintf file ")"
  in
  print_lambda_lambda' lambda;
  Format.fprintf file "@."
;;

let print_expr file expr =
  let rec print_expr_lambda' expr =
    match expr with
    | Variable v -> Format.fprintf file "%s" v
    | Identifier id -> Format.fprintf file "(%s)" id
    | Abstraction { param; body } ->
      Format.fprintf file "(";
      Format.fprintf file "λ%s" param;
      Format.fprintf file ".";
      print_expr_lambda' body;
      Format.fprintf file ")"
    | Application { term; argum } ->
      Format.fprintf file "(";
      print_expr_lambda' term;
      print_expr_lambda' argum;
      Format.fprintf file ")"
  in
  print_expr_lambda' expr;
  Format.fprintf file "@."
;;

let print_stmt file stmt =
  let rec print_stmt_lambda' stmt =
    match stmt with
    | Unit -> ()
    | Include f -> Format.fprintf file "include \"%s\"" f
    | Term e -> print_expr file e
    | Atribution { ident; value } ->
      Format.fprintf file "%s=" ident;
      print_expr file value
    | Sequence { s1; s2 } ->
      print_stmt_lambda' s1;
      print_stmt_lambda' s2
  in
  print_stmt_lambda' stmt
;;

let print_env file env =
  Hashtbl.iter
    (fun ident expr ->
      Format.fprintf file "%s=" ident;
      print_expr file expr)
    env
;;
