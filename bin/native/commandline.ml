let program_name = "main"
let input = ref ""
let output = ref ""
let library = ref ""
let interactive = ref false
let parse_only = ref false
let print_ocaml = ref false

let usage =
  Format.sprintf
    "usage: ./%s.exe [options] [file]\n\n\
     Lambda Calculus System\n\n\
     EXAMPLES\n\n\
     ./%s.exe input.txt\n\
     ./%s.exe input.txt -o output.txt\n\
     ./%s.exe input.txt -o output.txt -L standard/library.lambda\n\n\
     ./%s.exe --interactive\n\
     ./%s.exe --interactive -L standard/library.lambda\n\n\
     OPTIONS\n"
    program_name
    program_name
    program_name
    program_name
    program_name
    program_name
;;

let options =
  [ "-o", Arg.String (fun s -> output := s), "file\t\toutput to file\n"
  ; "-L", Arg.String (fun s -> library := s), "file\t\tinclude library\n\nFLAGS\n"
  ; "--parse-only", Arg.Set parse_only, "\t\tstop after parsing"
  ; "--interactive", Arg.Set interactive, "\truns interactively\n\nHELP\n"
  ; "-h", Arg.Unit (fun _ -> ()), "\t\t\tprint this help menu"
  ; "-help", Arg.Unit (fun _ -> ()), "\t\tprint this help menu"
  ; "--help", Arg.Unit (fun _ -> ()), "\t\tprint this help menu"
  ]
;;

let argument s = input := s
