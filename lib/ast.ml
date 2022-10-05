module Context = Map.Make (String)

type lambda =
  | Var of string
  | Abs of
      { param : string
      ; body : lambda
      }
  | App of
      { term : lambda
      ; argum : lambda
      }

type closure =
  | Closure of
      { context : closure Context.t
      ; lambda : lambda
      }

type expr =
  | Variable of string
  | Identifier of string
  | Abstraction of
      { param : string
      ; body : expr
      }
  | Application of
      { term : expr
      ; argum : expr
      }

type stmt =
  | Unit
  | Term of expr
  | Sequence of
      { s1 : stmt
      ; s2 : stmt
      }
  | Include of string
  | Atribution of
      { ident : string
      ; value : expr
      }
