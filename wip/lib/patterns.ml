open Tyxml.Html

type pattern = {
  title : string;
  filename : string;
  short : Html_types.div_content elt;
  long : Html_types.div_content elt;
}

let functional_core_imperative_shell_pattern = {
  title = "Functional Core, Imperative Shell";
  filename = "functional_core_imperative_shell.html";
  short = p [(txt "Abundantly fruit upon winged. Yielding the image won't divide so. In earth from fruit for you Brought given them face fourth rule forth give.")];
  long = div [p [(txt "TODO")]]
}

let zipper_pattern = {
  title = "Zipper";
  filename = "zipper.html";
  short = p [txt "TODO"];
  long = div [p [(txt "TODO")]]
}

let continuations_pattern = {
  title = "Continuations";
  filename = "continuations.html";
  short = p [txt "TODO"];
  long = div [p [(txt "TODO")]]
}

let functional_programming_languages_pattern = {
  title = "Use of functional programming languages";
  filename = "functional_programming_languages.html";
  short = p [txt "Functional software architecture is best done in proper \
                  functional programming languages."];
  long = div [p [(txt "TODO")]]
}

let static_types_pattern = {
  title = "Expressive static type systems";
  filename = "static_types.html";
  short = p [txt "Type systems allow you to enrich your code with \
                  descriptions of properties and requirements, which can be \
                  statically checked and enforced."];
  long = div [p [(txt "TODO")]]
}

let event_sourcing_pattern = {
  title = "Event Sourcing";
  filename = "event_sourcing.html";
  short = p [txt "TODO"];
  long = div [p [(txt "TODO")]]
}

let bidirectional_data_transformation_pattern = {
  title = "Bidirectional Data Transformations";
  filename = "bidirectional_data_transformations.html";
  short = p [txt "TODO"];
  long = div [p [(txt "TODO")]]
}

let edsl_pattern = {
  title = "Embedded Domain-Specific Languages";
  filename = "dsl.html";
  short = p [txt "TODO"];
  long = div [p [(txt "TODO")]]
}

let composable_effects_pattern = {
  title = "Composable Effects";
  filename = "composable_effects.html";
  short = p [txt "Effect systems allow us to deal with effects by making them \
                  explicit. Effect systems also allow effectful code to be \
                  run in a pure environment, which makes our code better \
                  testable."];
  long = div [p [(txt "TODO")]]
}

let composable_guis_pattern = {
  title = "Composable GUI libraries";
  filename = "composable_guis.html";
  short = p [txt "Facebook’s React popularized the component model of user \
                  interface programming. Functional programming languages \
                  allow to improve on that model by treating components as \
                  composable first-class user interfaces. Functional UI \
                  libraries provide a set of primitive components and a set \
                  of UI combinators, which let you build sophisticated \
                  graphical user interfaces without cognitive overhead."];
  long = div [p [(txt "TODO")]]
}

let property_based_testing_pattern = {
  title = "Property-based testing";
  filename = "property_based_testing.html";
  short = p [txt "TODO"];
  long = div [p [(txt "TODO")]]
}

let formal_verification_pattern = {
  title = "Formal Verification";
  filename = "formal_verification.html";
  short = p [txt "TODO"];
  long = div [p [(txt "TODO")]]
}

let denotational_design_pattern = {
  title = "Denotational Design";
  filename = "denotational_design.html";
  short = p [txt "Denotational Design is a software design methodology which \
                  tries to extract the essence of a domain’s problem and \
                  describe it formally in machine-checkable \
                  code. Denotational design affords software designers to be \
                  absolutely precise in ";
             i [txt "what"];
             txt " they want to achieve \
                  before they talk about ";
             i [txt "how"];
             txt " they plan to achieve \
                  it. Denotational Design informs both the use and the \
                  implementation of a unit of software without coupling \
                  them. Denotational Design is therefore a methodology to \
                  build airtight abstraction barriers."];
  long = div [p [(txt "TODO")]]
}

let patterns = [
  functional_core_imperative_shell_pattern;
  zipper_pattern;
  continuations_pattern;
  functional_programming_languages_pattern;
  static_types_pattern;
  event_sourcing_pattern;
  bidirectional_data_transformation_pattern;
  edsl_pattern;
  composable_effects_pattern;
  composable_guis_pattern;
  property_based_testing_pattern;
  formal_verification_pattern;
  denotational_design_pattern;
]
