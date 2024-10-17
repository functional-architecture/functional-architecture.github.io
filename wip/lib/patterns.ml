open Tyxml.Html

type pattern = {
  title : string;
  short : Html_types.div_content elt;
}

let functional_core_imperative_shell_pattern = {
  title = "Functional Core, Imperative Shell";
  short = p [(txt "Abundantly fruit upon winged. Yielding the image won't divide so. In earth from fruit for you Brought given them face fourth rule forth give.")]
}

let zipper_pattern = {
  title = "Zipper";
  short = p [txt "TODO"]
}

let continuations_pattern = {
  title = "Continuations";
  short = p [txt "TODO"]
}

let functional_programming_languages_pattern = {
  title = "Use of functional programming languages";
  short = p [txt "Functional software architecture is best done in proper \
                  functional programming languages."]
}

let static_types_pattern = {
  title = "Expressive static type systems";
  short = p [txt "Type systems allow you to enrich your code with \
                  descriptions of properties and requirements, which can be \
                  statically checked and enforced."]
}

let event_sourcing_pattern = {
  title = "Event Sourcing";
  short = p [txt "TODO"]
}

let bidirectional_data_transformation_pattern = {
  title = "Bidirectional Data Transformations";
  short = p [txt "TODO"]
}

let edsl_pattern = {
  title = "Embedded Domain-Specific Languages";
  short = p [txt "TODO"]
}

let composable_effects_pattern = {
  title = "Composable Effects";
  short = p [txt "Effect systems allow us to deal with effects by making them \
                  explicit. Effect systems also allow effectful code to be \
                  run in a pure environment, which makes our code better \
                  testable."]
}

let composable_guis_pattern = {
  title = "Composable GUI libraries";
  short = p [txt "Facebook’s React popularized the component model of user \
                  interface programming. Functional programming languages \
                  allow to improve on that model by treating components as \
                  composable first-class user interfaces. Functional UI \
                  libraries provide a set of primitive components and a set \
                  of UI combinators, which let you build sophisticated \
                  graphical user interfaces without cognitive overhead."]
}

let property_based_testing_pattern = {
  title = "Property-based testing";
  short = p [txt "TODO"]
}

let formal_verification_pattern = {
  title = "Formal Verification";
  short = p [txt "TODO"]
}

let denotational_design_pattern = {
  title = "Denotational Design";
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
                  build airtight abstraction barriers."]
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
