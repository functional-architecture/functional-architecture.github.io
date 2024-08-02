---
layout: page
title: Functional Software Architecture
subtitle: Functional Programming in the Large
---

<!--

TODO: _who_ is talking to _whom_ here?  e.g. should we say: "We value
correctness. If you do too, do X." (active) or should we say:
"Correctness is paramount. Correctness necessitates precise
specification." (passive)

The former sounds more manifesto-style while the latter may sound more
objective.

-->

<!-- Intro -->

"Functional Software Architecture" refers to methods of construction
and structure of large and long-lived software projects that are
implemented in functional languages and released to real users,
typically in industry.

We strive for&nbsp;…

<!-- TODO: Where to put something like the discussion on DDD vs. FP? -->

<!-- Why: -->

## Simplicity

Software design is fundamentally a human endeavour. Simple systems
allow for more reasoning bandwith between the software and its
designer.

Problem domains are complex enough. The solutions we build should be
as simple as possible.

Abundantly fruit upon winged. Yielding the image won't divide so. In
earth from fruit for you Brought given them face fourth rule forth
give.

Lights earth creeping, after divide let said make they're upon can't
moved have may created land together shall void multiply great. Very
he brought was was, second fly.

Models, composition, better abstractions

## Maintainabilty and Malleability

Abundantly fruit upon winged. Yielding the image won't divide so. In
earth from fruit for you Brought given them face fourth rule forth
give.

Lights earth creeping, after divide let said make they're upon can't
moved have may created land together shall void multiply great. Very
he brought was was, second fly.

## Correctness

We value software being correct both in the small and in the large.

Abundantly fruit upon winged. Yielding the image won't divide so. In
earth from fruit for you Brought given them face fourth rule forth
give.

Lights earth creeping, after divide let said make they're upon can't
moved have may created land together shall void multiply great. Very
he brought was was, second fly.

Specifications, formal methods ...

## Robustness

Abundantly fruit upon winged. Yielding the image won't divide so. In
earth from fruit for you Brought given them face fourth rule forth
give.

Lights earth creeping, after divide let said make they're upon can't
moved have may created land together shall void multiply great. Very
he brought was was, second fly.

Testability, specifications

## Performance

Software has to be both correct and fast. If software were not fast,
computers would be obsolete.

Lights earth creeping, after divide let said make they're upon can't
moved have may created land together shall void multiply great. Very
he brought was was, second fly.


<!-- What: -->
# Principles

## Immutable architecture

Values, (pure) functions, composition

## Powerful models

Math-based abstractions, combinators

## Airtight abstractions

Formal specification

## Architecture as Code

Expressiveness

## Loose coupling

Fewer hidden dependencies

<!-- How: -->
# Patterns, Tools, and Techniques

## Functional core, imperative shell

## Use of functional programming languages

## Expressive static type systems

## Event sourcing

## Bidirectional data transformation

## Embedded Domain Specific Languages

## Effect systems

## Composable GUI frontends

Elm Architecture, Model-View-Update, reacl

## Property-based Testing

## Formal verification

# Frequently Asked Questions

## Is there a class of domains where Functional Software Architecture works exceptionally well? Is there a class of domains where Functional Software Architecture fails?

No

## External systems usually don't follow FSA principles. How do you interface with them?

Spec out their behaviour, making time (or state transitions) explicit. Ask for guarantees that the external service provides.

## I want to [do X]. What techniques or libraries should I use?

### I want to build a web frontend

Elm architecture, Model-View-Update, reacl

### I want to build a web server

Handlers as functions from request to response (Clojure ring, OCaml Dream ...)

### I need to access a RDBMS

...

### I need to serialize objects to send them back and forth over a channel

bidirectional data transformations, lenses

## I heard that functional programming suffers a performance penalty compared to imperative programming. Is that right?

It depends.

## Is Domain-Driven Design at odds with functional modelling?

It depends.
