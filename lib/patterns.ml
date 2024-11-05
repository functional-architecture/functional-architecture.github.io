open Tyxml.Html

type pattern = {
  title : string;
  route : string;
  short : Html_types.div_content elt;
  long : Html_types.div_content elt;
}

let functional_core_imperative_shell_pattern = {
  title = "Functional Core, Imperative Shell";
  route = "functional_core_imperative_shell";
  short = p [(txt "Abundantly fruit upon winged. Yielding the image won't divide so. In earth from fruit for you Brought given them face fourth rule forth give.")];
  long = div [p [(txt "TODO")]]
}

let zipper_pattern = {
  title = "Zipper";
  route = "zipper";
  short = p [txt "TODO"];
  long = div [p [(txt "TODO")]]
}

let continuations_pattern = {
  title = "Continuations";
  route = "continuations";
  short = p [txt "TODO"];
  long = div [p [(txt "TODO")]]
}

let functional_programming_languages_pattern = {
  title = "Use of functional programming languages";
  route = "functional_programming_languages";
  short = p [txt "Functional software architecture is best done in proper \
                  functional programming languages."];
  long = div [p [(txt "TODO")]]
}

let static_types_pattern = {
  title = "Expressive static type systems";
  route = "static_types";
  short = p [txt "Type systems allow you to enrich your code with \
                  descriptions of properties and requirements, which can be \
                  statically checked and enforced."];
  long = div [p [(txt "TODO")]]
}

let event_sourcing_pattern = {
  title = "Event Sourcing";
  route = "event_sourcing";
  short = p [txt "TODO"];
  long = div [p [(txt "TODO")]]
}

let bidirectional_data_transformation_pattern = {
  title = "Bidirectional Data Transformations";
  route = "bidirectional_data_transformations";
  short = p [txt "Different components of a system may need the same \
                  information but may have different demands on its \
                  structure. We employ bidirectional data \
                  transformations with functional optics to simplify \
                  conversions from one representation to the next."];
  long = (Markdown.from_markdown_file "./patterns/bidirectional_data_transformations.md")
}

let edsl_pattern = {
  title = "Embedded Domain-Specific Languages";
  route = "dsl";
  short = p [txt "TODO"];
  long = div [p [(txt "TODO")]]
}

let composable_effects_pattern = {
  title = "Composable Effects";
  route = "composable_effects";
  short = p [txt "Effect systems allow us to deal with effects by making them \
                  explicit. Effect systems also allow effectful code to be \
                  run in a pure environment, which makes our code better \
                  testable."];
  long = div [p [(txt "TODO")]]
}

let composable_guis_pattern = {
  title = "Composable GUI libraries";
  route = "composable_guis";
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
  route = "property_based_testing";
  short = p [txt "TODO"];
  long = div [p [(txt "TODO")]]
}

let formal_verification_pattern = {
  title = "Formal Verification";
  route = "formal_verification";
  short = p [txt "TODO"];
  long = div [p [(txt "TODO")]]
}

let denotational_design_pattern = {
  title = "Denotational Design";
  route = "denotational_design";
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

let parse_dont_validate_pattern = {
  title = "Parse, don’t validate";
  route = "parse_dont_validate";
  short = p [txt "«Parse, don’t validate» is a simple mnemonic for \
                  type-driven design."];
  long = div [p [txt "TODO"]]
}

let trees_that_grow_pattern = {
  title = "Trees that grow";
  route = "trees_that_grow";
  short = p [txt "«Trees that grow» is a method to make models built \
                  with algebraic data types more extensible."];
  long = div [p [txt "TODO"]]
}

let data_types_a_la_carte_pattern = {
  title = "Data types à la carte";
  route = "data_types_a_la_carte";
  short = p [txt "«Data types à la carte» is a technique to deal with \
                  the dreaded Expression Problem in functional \
                  languages."];
  long = div [p [txt "TODO"]];
}

let smart_constructor_pattern = {
  title = "Smart constructor";
  route = "smart_constructor";
  short = p [txt "A smart constructor semantically behaves like any \
                  ordinary constructor, but it performs some useful \
                  computations such as preprocessing, normalization, \
                  parsing, or validation."];
  long = div [p [txt "TODO"]];
}

let correctness_by_construction_pattern = {
  title = "Correctness by Construction";
  route = "correctness_by_construction";
  short = p [txt "TODO"];
  long = div [p [txt "TODO"]];
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
  parse_dont_validate_pattern;
  trees_that_grow_pattern;
  data_types_a_la_carte_pattern;
  smart_constructor_pattern;
  correctness_by_construction_pattern;
]
