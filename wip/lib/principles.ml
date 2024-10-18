open Tyxml.Html

type principle = {
    title : string;
    filename : string;
    short : string;
    long : Html_types.div_content elt option;
}

let immutability_principle = {
  title = "Immutability";
  filename = "immutability.html";
  short = "Stop thinking in terms of state and resource management and \
           start thinking in terms of your domain.";
  long = Some (txt "Ja moin");
}

let purity_principle = {
  title = "Pure Functions";
  filename = "pure_functions.html";
  short = "A pure function transforms immutable values without \
           performing any side effects.";
  long = None;
}

let everything_as_a_value_principle = {
  title = "Everything as a Value";
  filename = "eaav.html";
  short = "Reifying concepts as values allows these concepts to \
           be passed around, analyzed and composed. Functions as \
           values, property accessors as values, UI components as \
           values ...";
  long = Some (div [
      p [
        txt "Every software is _about_ something: A simple calculator \
             application is about numbers and operations thereon, an \
             anomaly detection application is about time series, an \
             operating system is about system resources. Applications \
             are usually split into different components. One \
             component may be about something else than another \
             component inside the same application. In an anomaly \
             detection application, the visualization component may be \
             about charts and graphs, whereas the storage module may \
             be about SQL queries."
      ];
      p [strong [
          txt "In any of these cases where a piece of software is about \
               a concept, we have a choice of either blindly programming \
               around the concept or making the concept an explicit part \
               of our programming model."
        ];
         txt "For example the aforementioned visualization component \
              could take in byte arrays and draw pixels on the screen, \
              without ever mentioning the concept of a graph in the \
              code. Or it could make the concept of a graph an \
              explicit part of its language. The component may still \
              need to accept byte arrays as input, but it could \
              translate these byte arrays into its idea of time \
              series, then turn these time series into graphs and then \
              render these graphs as pixels on screen. In Functional \
              Software Architecture we strongly favor the latter \
              approach. The technique of turning formerly implicit \
              concepts into explicit devices of the software is often \
              called 'reification' or 'internalizing' or we say that \
              we make the concept 'first-class'."
        ];
      h2 [txt "Successful Examples of Reification"];
      p [
        txt "Some of the most profound advances in software \
             engineering are due to internalizing formerly vague and \
             implicit concepts."
      ];

      h3 [txt "Functions as first-class procedures"];
      p [txt "On of the first linguistic devices in programming were \
              procedural abstractions. A procedure is a snippet of \
              code that is written down once and can be called from \
              many different places with different \
              parameters. Functional programming improved on this \
              primitive notion by making procedures first-class \
              values: Procedures could now not just be named and \
              invokes but also passed around to other procedures \
              (making these procedures 'higher-order') just like \
              integers, characters, lists, etc."];
        p [txt "Functions as first-class values allows for more \
                expressive and modular, and therefore reusable code."];

      h3 [txt "Jolie: Services as first-class values"];
      p [txt "In the Jolie programming language, you compose small \
              services to form larger services. In the words of the language maintainers:"];
      blockquote [txt "Jolie crystallises the programming concepts of \
                       service-oriented computing as linguistic \
                       constructs. The basic building blocks of \
                       software are not objects or functions, but \
                       rather services that can be relocated and \
                       replicated as needed. A composition of services \
                       is a service."];
    ]);
}

let composition_principle = {
  title = "Composition and Closure";
  filename = "composition.html";
  short = "We like to combine small software structures to form larger structures – without cognitive overhead.";
  long = None;
}

let algebra_principle = {
  title = "Algebraic models";
  filename = "algebra.html";
  short = "Functional software architects try to find models that \
           build on algebraic structures that stood the test of time, \
           such as Monoids, Functors, and Monads.";
  long = None;
}

let abstraction_principle = {
  title = "Airtight Abstractions";
  filename = "abstraction.html";
  short = "Abstraction is the sharpest weapon of reason. Functional \
           software architects welcome abstraction as a tool for \
           coping with complexity.";
  long = None;
}

let architecture_as_code_principle = {
  title = "Architecture as Code";
  filename = "aac.html";
  short = "In functional software architecture we use diagrams and \
           descriptions as supporting documentation, but the source of \
           truth is always to be found in the code.";
  long = None;
}

let rec html_from_markdown_inline (md : Omd.attributes Omd.inline)
  : [>] elt =
  match md with
  | Concat (_attr, children) -> span (List.map html_from_markdown_inline children)
  | Text (_attr, s) -> txt s
  | Emph (_attr, child) -> em [(html_from_markdown_inline child)]
  | Strong (_attr, child) -> strong [(html_from_markdown_inline child)]
  | Code (_attr, str) -> code [(txt str)]
  | Hard_break _attr -> br ()
  | Soft_break _attr -> txt "\n"
  | Link (_attr, _link) -> txt "TODO"
  | Image (_attr, _link) -> txt "TODO"
  | Html (_attr, _raw) -> txt "TODO"

let h = function
  | 1 -> h1
  | 2 -> h2
  | 3 -> h3
  | 4 -> h4
  | 5 -> h5
  | _ -> h6

let rec html_from_markdown_ (md : Omd.attributes Omd.block)
  : [>] elt =

  let open Omd in
  match md with
  | Paragraph (_attr, children) -> p [(html_from_markdown_inline children)]
  | List (_, _, _, _) -> txt "TODO"
  | Blockquote (_attr, children) -> blockquote (List.map html_from_markdown_ children)
  | Thematic_break _attr -> p []
  | Heading (_attr, lvl, children) -> (h lvl) [(html_from_markdown_inline children)]
  | Code_block (_attr, _label, code) -> pre [txt code]
  | Html_block (_attr, _raw) -> txt "TODO"
  | Definition_list (_attr, _definitions) -> txt "TODO"
  | Table (_attr, _header, _body) -> table []

let html_from_markdown (mds : Omd.doc) =
  div (List.map html_from_markdown_ mds)

let from_markdown_file file =
  let open Omd in
  let md = of_channel file in
  let sexp = to_sexp md in
  print_endline sexp;
  (html_from_markdown md)

let decoupled_by_default_file = open_in "./principles/decoupled_by_default.md"

let decoupled_by_default_principle = {
  title = "Decoupled by Default";
  filename = "dbd.html";
  short = "Make the communication channels between building blocks as \
           wide as neccessary and as narrow as possible.";
  long = Some (from_markdown_file decoupled_by_default_file);
}

let principles = [
  immutability_principle;
  purity_principle;
  everything_as_a_value_principle;
  composition_principle;
  algebra_principle;
  abstraction_principle;
  architecture_as_code_principle;
  decoupled_by_default_principle;
]
