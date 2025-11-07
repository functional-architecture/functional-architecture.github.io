open Tyxml.Html

type 'a publishing_state =
  | Published of 'a
  | Draft of 'a
  | Todo

type principle = {
    title : string;
    route : string;
    short : string;
    long : Html_types.div_content elt publishing_state;
}

let immutability_principle = {
  title = "Immutability";
  route = "immutability";
  short = "Stop thinking in terms of state and resource management and \
           start thinking in terms of your domain.";
  long = Todo;
}

let purity_principle = {
  title = "Pure Functions";
  route = "pure_functions";
  short = "A pure function transforms immutable values without \
           performing any side effects.";
  long = Todo;
}

let everything_as_a_value_principle = {
  title = "Everything as a Value";
  route = "eaav";
  short = "Reifying concepts as values allows these concepts to \
           be passed around, analyzed and composed. Functions as \
           values, property accessors as values, UI components as \
           values ...";
  long = Draft (div [
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
  route = "composition";
  short = "We like to combine small software structures to form larger structures – without cognitive overhead.";
  long = Todo;
}

let algebra_principle = {
  title = "Algebraic Modelling";
  route = "algebra";
  short = "Functional software architects try to find models that build on \
           algebraic patterns that stood the test of time, by using properties \
           like Associativity and Distributivity that form structures such as \
           Monoids, Functors, and Monads.";
  long = Published (Markdown.from_markdown_file "./principles/algebraic_modelling.md");
}

let abstraction_principle = {
  title = "Airtight Abstractions";
  route = "abstraction";
  short = "Abstraction is the sharpest weapon of reason. Functional \
           software architects welcome abstraction as a tool for \
           coping with complexity.";
  long = Todo;
}

let architecture_as_code_principle = {
  title = "Architecture as Code";
  route = "aac";
  short = "Functional Software Architecture allows many architectural \
           decisions to be expressed in code. We may still use \
           diagrams and descriptions as supporting documentation, but \
           the source of truth is always to be found in the code.";
  long = Todo;
}

let decoupled_by_default_principle = {
  title = "Decoupled by Default";
  route = "dbd";
  short = "Make the communication channels between building blocks as \
           wide as necessary and as narrow as possible. Build tools \
           with affordances toward low coupling and high cohesion.";
  long = Draft (Markdown.from_markdown_file "./principles/decoupled_by_default.md");
}

let late_decision_making_principle = {
  title = "Late Decision Making";
  route = "late";
  short = "Software design is usually performed under \
           uncertainty. Instead of trying to make the right decisions \
           up front, we want to design our systems in such a way that \
           it is easy to change our minds later in the process. This \
           shifts our focus from making decisions to making decisions \
           possible.";
  long = Draft (Markdown.from_markdown_file "./principles/late_decision_making.md");
}

let modularization_principle = {
  title = "Modularization";
  route = "modularization";
  short = "Modules hide difficult decisions behind simple \
           interfaces. While modularization is not an exclusive \
           feature of functional architectures, functional \
           abstractions allow for simpler interfaces and therefore \
           allow to hide more decisions, leading to more malleable \
           designs overall.";
  long = Todo;
}

let misu to_static_types to_parse_dont_validate to_smart_constructor =
  Markdown.function_of_parameterized_markdown
    "./principles/make_illegal_states_unrepresentable.md"
    ["{{link_static_types}}";
     "{{link_parse_dont_validate}}";
     "{{link_smart_constructor}}";]
    [to_static_types;
     to_parse_dont_validate;
     to_smart_constructor;]

let make_illegal_states_unrepresentable_principle
    to_static_types
    to_parse_dont_validate
    to_smart_constructor = {
  title = "Make Illegal States Unrepre\u{00AD}sentable";
  route = "make_illegal_states_unrepresentable";
  short = "«Make illegal states unrepresentable» is a \
           functional design technique that leverages product \
           and sum types to decrease the bug surface of your \
           software.";
  long = Published (misu to_static_types to_parse_dont_validate to_smart_constructor);
}
