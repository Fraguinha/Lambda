{
  open Parser

  let buffer = Buffer.create 1024
}

let space = [' ' '\t']

let newline = '\n' | '\r' | "\r\n"

let lower = ['a'-'z']

let upper = [ '_' 'A'-'Z' '0'-'9' '[' ']' ':']

let var = lower '\''*

let term = upper+ '\''*

rule token = parse
  | space
  | newline       { token lexbuf }
  | "(*"          { comment lexbuf; token lexbuf }
  | "\""          { string lexbuf }
  | "("           { LP }
  | ")"           { RP }
  | "λ"           { LAMBDA }
  | "\\"          { LAMBDA }
  | "."           { DOT }
  | "="           { ATRIB }
  | ";"           { SEMICOLON }
  | "include"     { INCLUDE }
  | var as v      { VAR v }
  | term as t     { TERM t }
  | eof           { EOF }
  | _ as c        { failwith (Format.sprintf "Invalid character: %c" c) }

and comment = parse
  | "(*"  { comment lexbuf; comment lexbuf }
  | "*)"  { () }
  | _     { comment lexbuf }
  | eof   { failwith  "Unterminated comment" }

and string = parse
    | '"' {
      let s = Buffer.contents buffer in
      Buffer.reset buffer;
      STRING s
    }
  | "\\t" {
      Buffer.add_char buffer '\t';
      string lexbuf
    }
  | "\\n" {
      Buffer.add_char buffer '\n';
      string lexbuf
    }
  | "\\\"" {
      Buffer.add_char buffer '"';
      string lexbuf
    }
  | _ as c {
      Buffer.add_char buffer c;
      string lexbuf
    }
  | eof { failwith "Unterminated string" }
