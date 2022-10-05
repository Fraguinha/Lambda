open Ast

let rec free lambda =
  match lambda with
  | Var v -> [ v ]
  | Abs { param; body } -> List.filter (fun x -> x <> param) (free body)
  | App { term; argum } -> free term @ free argum
;;

let b_reduction lambda =
  let closure_of_lambda lambda = Closure { context = Context.empty; lambda } in
  let lambda_of_closure (Closure { context = _; lambda }) = lambda in
  let rec b_reduction' (Closure { context; lambda }) =
    match lambda with
    | Var v ->
      if Context.mem v context
      then Context.find v context
      else Closure { context; lambda }
    | Abs _ -> Closure { context; lambda }
    | App { term; argum } ->
      let argument = b_reduction' (Closure { context; lambda = argum }) in
      (match b_reduction' (Closure { context; lambda = term }) with
       | Closure { context; lambda = Abs { param; body } } ->
         let context = Context.add param argument context in
         b_reduction' (Closure { context; lambda = body })
       | Closure { context = _; lambda = term } ->
         let (Closure { context = _; lambda = argum }) = argument in
         Closure { context; lambda = App { term; argum } })
  in
  lambda |> closure_of_lambda |> b_reduction' |> lambda_of_closure
;;

let rec n_reduction lambda =
  match lambda with
  | Var _ -> lambda
  | Abs { param; body = App { term; argum = Var var } } ->
    if param = var && not (List.mem var (free term)) then term else lambda
  | Abs { param; body } ->
    let body' = n_reduction body in
    if body' <> body then n_reduction (Abs { param; body = body' }) else lambda
  | App { term; argum } ->
    let term = n_reduction term in
    let argum = n_reduction argum in
    App { term; argum }
;;

let eval lambda = lambda |> b_reduction |> n_reduction
