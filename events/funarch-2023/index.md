---
layout: page
title: FUNARCH 2023
description: The First ACM SIGPLAN Workshop on Functional Software Architecture - FP in the Large
img: assets/img/funarch-logo.jpg
---

"Functional Software Architecture" refers to methods of construction
and structure of large and long-lived software projects that are
implemented in functional languages and released to real users,
typically in industry.

The goals for the workshop are:

- To assemble a community interested in software architecture
  techniques and technologies specific to functional programming;

- To identify, categorize, and document topics relevant to
  the field of functional software architecture;

- To connect the functional programming community to the software
  architecture community to cross-pollinate between the two.
    
FUNARCH 2023 will be co-colocated with [ICFP 2023](https://icfp23.sigplan.org/)
in Seattle on 8th September 2023.

News is available on [Mastodon](https://discuss.systems/@funarch) and
[Twitter](https://twitter.com/ACMFUNARCH).

## Program

### A Software Architecture Based on Coarse-Grained Self-Adjusting Computations
#### Stefan Wehr

Ensuring that software applications present their users the most
recent version of data is not trivial. Self-adjusting com- putations
are a technique for automatically and efficiently recomputing output
data whenever some input changes. This article describes the software
architecture of a large, commercial software system built around a
framework for coarse-grained self-adjusting computations in
Haskell. It discusses advantages and disadvantages based on longtime
experience. The article also presents a demo of the system and
explains the API of the framework

### Crème de la Crem: Composable Representable Executable Machines
#### Marco Perone, Georgios Karachalias

In this paper we describe how to build software architectures as a
composition of state machines, using ideas and principles from the
field of Domain-Driven Design. By definition, our approach is modular,
allowing one to compose independent subcomponents to create bigger
systems, and representable, allowing the implementation of a system to
be kept in sync with its graphical representation. In addition to the
design itself we introduce the Crem library, which provides a concrete
state machine implemen- tation that is both compositional and
representable. Crem uses Haskell’s advanced type-level features to
allow users to specify allowed and forbidden state transitions, and to
en- code complex state machine—and therefore domain-specific—
properties. Moreover, since Crem’s state machines are repre- sentable,
Crem can automatically generate graphical repre- sentations of systems
from their domain

### Functional Shell and Reusable Components for Easy GUIs
#### Ben Knoble, Bogdan Popa

Some object-oriented GUI toolkits tangle state management with
rendering. Functional shells and observable toolkits like GUI Easy
simplify and promote the creation of reusable views by analogy to
functional programming. We have suc- cessfully used GUI Easy on small
and large GUI projects. We report on our experience constructing and
using GUI Easy and derive from that experience several architectural
patterns and principles for building functional programs out of
imperative systems

### Phases in Software Architecture
#### Jeremy Gibbons, Oisín Kidney, Tom Schrijvers, Nicolas Wu

The large-scale structure of executing a computation can often be
thought of as being separated into distinct phases. But the most
natural form in which to specify that computa- tion may well have a
different and conflicting structure. For example, the computation
might consist of gathering data from some locations, processing it,
then distributing the re- sults back to the same locations; it may be
executed in three phases—gather, process, distribute—but mostly
conveniently specified orthogonally—by location. We have recently
shown that this multi-phase structure can be expressed as a novel
applicative functor (also known as an idiom, or lax monoidal
functor). Here we summarize the idea from the perspective of software
architecture. At the end, we speculate about applications to
choreography and multi-tier architecture.

### Stretching the Glasgow Haskell Compiler
#### Jeffrey M. Young, Sylvain Henry, John Ericson

Over the last decade Haskell has been productized; transi- tioning
from a research language to an industrial strength language ready for
large-scale systems. However, the liter- ature on architecting such
systems with a pure functional language is scarce. In this paper we
contribute to that discourse, by using a large-scale system: the
Glasgow Haskell Compiler (GHC) itself, as a guide to more main-
tainable, flexible and effective pure functional software
architectures. We describe, from experience working on GHC, how GHC as
a system, violates the desirable prop- erties that make pure
functional programming attractive: immutability, modularity, and
composability. With these violations identified, we provide actionable
guidance for other functional system architectures; drawing heavily on
domain-driven design. We write this paper from an en- gineering
perspective, with the hope that our collection and recapitulation may
provide insight into future best practices for other pure functional
software architects.


### Typed Design Patterns for the Functional Era
#### Will Crichton

This paper explores how design patterns could be revisited in the era
of mainstream functional programming languages. I discuss the kinds of
knowledge that ought to be represented as functional design patterns:
architectural concepts that are relatively self-contained, but whose
entirety cannot be represented as a language-level abstraction. I
present four concrete examples embodying this idea: the Witness, the
State Machine, the Parallel Lists, and the Registry. Each pat- tern is
implemented in Rust to demonstrate how careful use of a sophisticated
type system can better model each domain construct and thereby catch
user mistakes at compile-time.

### Types that Change: The Extensible Type Design Pattern
#### Ivan Perez

Compilers are often structured as chains of transformations, from
source code to object code, through multiple intermediate repre-
sentations. The existence of different representations of the same
program presents challenges both for code maintenance and in terms of
architecture. The types used to capture programs at multi- ple stages
may be similar but not interchangeable, leading to code
duplication. Methods to alleviate such duplication often lead to
violations of software engineering principles of abstraction and
encapsulation. This pearl discusses a design pattern where an alge-
braic data type (ADT) is extended with an argument type function that
is applied to every component of the ADT. The resulting para- metric
type can be instantiated with multiple type functions, each providing
a different feature. We demonstrate the versatility of this pattern by
capturing notions of traceability and error recovery, and demonstrate
that it can also be used to selectively modify existing types, as well
as to extend them. Our proposal has been validated by applying it to a
real-world use case with very good results.
