let program_name = "main"
let input = ref ""
let output = ref ""
let library = ref ""
let parse_only = ref false
let pretty_print = ref false
let interactive = ref false

let usage =
  Format.sprintf
    "usage: ./%s.exe [options] file\n\n\
     Lambda Calculus Interpreter/Compiler\n\n\
     EXAMPLES\n\n\
     ./%s.exe input.txt\n\
     ./%s.exe input.txt -o output.txt\n\
     ./%s.exe input.txt -o output.txt -L lib/std.lambda\n\n\
     ./%s.exe --interactive\n\
     ./%s.exe --interactive lib/std.lambda\n\n\
     OPTIONS\n"
    program_name program_name program_name program_name program_name
    program_name

let options =
  [
    ("-o", Arg.String (fun s -> output := s), "file\t\toutput to file");
    ( "-L",
      Arg.String (fun s -> library := s),
      "file\t\tinclude library\n\nFLAGS\n" );
    ("-i", Arg.Set interactive, "\t\t\truns interactively\n");
    ("--parse-only", Arg.Set parse_only, "\t\tstop after parsing");
    ("--pretty-print", Arg.Set pretty_print, "\tpretty print AST");
    ("--interactive", Arg.Set interactive, "\truns interactively\n\nHELP\n");
    ("-h", Arg.Unit (fun _ -> ()), "\t\t\tprint this help menu");
    ("-help", Arg.Unit (fun _ -> ()), "\t\tprint this help menu");
    ("--help", Arg.Unit (fun _ -> ()), "\t\tprint this help menu");
  ]

let argument s = input := s
