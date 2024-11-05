type value = {
  title : string;
  short : string;
}

let simplicity_value = {
  title = "Simplicity";
  short = "Problem domains are complex enough. The solutions we build should be as simple as possible."
}

let domain_insight_value = {
  title = "Domain Insight";
  short = "Software development is about running software just as much as it is about gaining insight into a domain."
}

let maintainability_value = {
  title = "Maintainability";
  short = "Maintainability and malleability fundamentally enable the software creation process."
    (* Software architecture is often characterized as the set of
       difficult decisions that could make or break a project's
       success. Folklore in the classic software architecture
       community is that these decisions ara both (1) made in the
       uncertainty of early development and (2) hard to change. These
       difficult decisions therefore require skilled architects who
       just do the right thing with the help of their sheer
       intellectual prowess. With functional software architecture,
       our approach is the polar opposite: Since in the beginning of a
       project uncertainty is greatest, we should build our system in
       a way that allows to make these decisions later. Decisions
       being hard to change is not a function of the decision itself
       but a function of the software itself. We therefore prioritize
       maintainability, malleability, and modularization as primary
       enablers of the entire software creation
       process. Maintainability, malleability, and modularization are
       not just one category of software qualities among many
       others. These properties fundamentally support (or hinder) all
       the others. *)
}

let correctness_value = {
  title = "Correctness";
  short = "We value software being correct both in the small and in the large."
}

let performance_value = {
  title = "Performance";
  short = "Software has to be both correct and fast. If software were not fast, computers would be obsolete."
}

let values = [simplicity_value;
              domain_insight_value;
              maintainability_value;
              correctness_value;
              performance_value]
