open Ast

let rec free lambda =
  match lambda with
  | Var v -> [ v ]
  | Abs { param; body } -> List.filter (fun x -> x <> param) (free body)
  | App { term; argum } -> free term @ free argum

let rec bound lambda =
  match lambda with
  | Var _ -> []
  | Abs { param; body } -> param :: bound body
  | App { term; argum } -> bound term @ bound argum

let a_conversion lambda =
  let rec find_replacement variables var =
    let candidate = var ^ "'" in
    if List.mem candidate variables then find_replacement variables candidate
    else candidate
  in
  let rec replace variables bounded lambda =
    match lambda with
    | Var v ->
        if List.mem v variables && List.mem v bounded then
          let name = find_replacement variables v in
          Var name
        else lambda
    | Abs { param; body } ->
        let new_param =
          if List.mem param variables then find_replacement variables param
          else param
        in
        let body = replace variables (param :: bounded) body in
        Abs { param = new_param; body }
    | App { term; argum } ->
        let term = replace variables bounded term in
        let argum = replace variables bounded argum in
        App { term; argum }
  in
  let rec a_conversion_rec lambda =
    match lambda with
    | Var _ | Abs _ -> lambda
    | App { term; argum } ->
        let term = a_conversion_rec term in
        let argum = a_conversion_rec argum in
        let bv_left = bound term in
        let bv_right = bound argum in
        let fv_right = free argum in
        let captured =
          List.fold_left
            (fun captured x ->
              match List.mem x bv_left with
              | true -> x :: captured
              | false -> captured)
            [] fv_right
        in
        let reused =
          List.fold_left
            (fun reused x ->
              match List.mem x bv_left with
              | true -> x :: reused
              | false -> reused)
            [] bv_right
        in
        let term =
          match captured @ reused with
          | [] -> term
          | vars -> replace vars [] term
        in
        App { term; argum }
  in
  lambda |> a_conversion_rec

let b_reduction lambda =
  let rec substitute argument parameter lambda =
    match lambda with
    | Var v as variable -> if v = parameter then argument else variable
    | Abs { param; body } ->
        let body = substitute argument parameter body in
        Abs { param; body }
    | App { term; argum } ->
        let term = substitute argument parameter term in
        let argum = substitute argument parameter argum in
        App { term; argum }
  in
  let rec b_reduction_rec lambda =
    let lambda = lambda |> a_conversion in
    match lambda with
    | Var _ -> lambda
    | Abs { param; body } ->
        let body = b_reduction_rec body in
        Abs { param; body }
    | App { term = Abs { param; body }; argum } ->
        let body = substitute argum param body in
        b_reduction_rec body
    | App { term; argum } ->
        let term' = b_reduction_rec term in
        let argum' = b_reduction_rec argum in
        if term' <> term || argum' <> argum then
          b_reduction_rec (App { term = term'; argum = argum' })
        else App { term; argum }
  in
  lambda |> b_reduction_rec

let n_reduction lambda =
  let rec n_reduction_rec lambda =
    match lambda with
    | Var _ -> lambda
    | Abs { param; body = App { term; argum = Var var } } ->
        if param = var && not (List.mem var (free term)) then term else lambda
    | Abs { param; body } ->
        let body' = n_reduction_rec body in
        if body' <> body then n_reduction_rec (Abs { param; body = body' })
        else lambda
    | App { term; argum } ->
        let term = n_reduction_rec term in
        let argum = n_reduction_rec argum in
        App { term; argum }
  in
  lambda |> n_reduction_rec

let prettify lambda =
  let mappings = Hashtbl.create 257 in
  let letter = ref 96 in
  let rec new_name candidate =
    if Hashtbl.mem mappings candidate then
      let candidate = candidate ^ "'" in
      new_name candidate
    else candidate
  in
  let select_name var =
    try Hashtbl.find mappings var
    with Not_found ->
      incr letter;
      if !letter > 122 then letter := 97;
      let name = new_name (String.make 1 (Char.chr !letter)) in
      Hashtbl.add mappings var name;
      name
  in
  let rec prettify_rec lambda =
    match lambda with
    | Var v ->
        let v = select_name v in
        Var v
    | Abs { param; body } ->
        let param = select_name param in
        let body = prettify_rec body in
        Abs { param; body }
    | App { term; argum } ->
        let term = prettify_rec term in
        let argum = prettify_rec argum in
        App { term; argum }
  in
  lambda |> prettify_rec

let eval lambda = lambda |> b_reduction |> n_reduction |> prettify
