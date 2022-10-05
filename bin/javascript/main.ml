open Js_of_ocaml

let _ =
  Js.export
    "Interpreter"
    (object%js
       method parse_lambda input =
         let input = Js.to_string input in
         let lambda = Interpreter.parse_stmt input in
         match lambda with
         | None -> Js.string ""
         | Some lambda -> Js.string (Interpreter.string_of_lambda lambda)
    end)
;;
