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
    
FUNARCH 2023 was be co-colocated with [ICFP 2023](https://icfp23.sigplan.org/)
in Seattle on 8th September 2023.

News is available on [Mastodon](https://discuss.systems/@funarch) and
[Twitter](https://twitter.com/ACMFUNARCH).

## Proceedings

... are available from the [ACM Digital Library](https://dl.acm.org/doi/proceedings/10.1145/3609025).

## Code of Conduct

FUNARCH adheres to the [SIGPLAN/ICFP Code of Conduct](https://icfp23.sigplan.org/attending/code-of-conduct).

## Program

The videos are also available as a [YouTube playlist](https://www.youtube.com/playlist?list=PLyrlk8Xaylp7YIgF5E44NLqf34HmRzM-F).

### Functional Programming in the Large - Status and Perspective 
#### Mike Sperber
##### (Opening Talk)

Functional programming has been in use for large-scale industrial
projects for decades now.  Yet most of the community's vast body of
knowledge on how to structure and implement such project seems to be
folklore, with the occasional reference to ICFP or JFP papers.  This
is hardly a realistic offering for community outsiders.

Furthermore, the software architecture community has developed a large
body of useful knowledge, literature and pedagogy, largely unknown in
functional programming circles.  In particular, the hugely effective
set of techniques and insights associated with Domain-Driven Design
has seen very little cross-pollination with functional design
techniques, despite their shared goals.

If we want to bring the advantages of functional programming to
realistic, industrial projects not conducted by insiders, we will need
to learn to communicate with the software archtecture community.

This talk will report on our experience interacting with the software
architecture community, identify a few particularly fruitful areas of
potential cross-pollination, and try to take a long view on what
functional software architecture might look in the future.

<iframe width="560" height="315" src="https://www.youtube.com/embed/e9Go-iyIkhY?si=CPVtItbRCLPJmhbZ" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

### [A Software Architecture Based on Coarse-Grained Self-Adjusting Computations](https://dl.acm.org/doi/10.1145/3609025.3609481?cid=81100173259)
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

<iframe width="560" height="315" src="https://www.youtube.com/embed/3qUFx-luepQ?si=Lx2kiWPIsK03v5ae" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

### [Crème de la Crem: Composable Representable Executable Machines](https://dl.acm.org/doi/10.1145/3609025.3609480?cid=99660990271)
#### Marco Perone, Georgios Karachalias

In this paper we describe how to build software architectures as a
composition of state machines, using ideas and principles from the
field of Domain-Driven Design. By definition, our approach is modular,
allowing one to compose independent subcomponents to create bigger
systems, and representable, allowing the implementation of a system to
be kept in sync with its graphical representation. In addition to the
design itself we introduce the Crem library, which provides a concrete
state machine implementation that is both compositional and
representable. Crem uses Haskell’s advanced type-level features to
allow users to specify allowed and forbidden state transitions, and to
encode complex state machine—and therefore domain-specific
properties. Moreover, since Crem’s state machines are representable,
Crem can automatically generate graphical repre- sentations of systems
from their domain

<iframe width="560" height="315" src="https://www.youtube.com/embed/mh751JTgBdA?si=ZPTwHOjnlpNnzQ2g" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

### [Functional Shell and Reusable Components for Easy GUIs](https://defn.io/papers/fungui-funarch23.pdf)
#### Ben Knoble, Bogdan Popa

Some object-oriented GUI toolkits tangle state management with
rendering. Functional shells and observable toolkits like GUI Easy
simplify and promote the creation of reusable views by analogy to
functional programming. We have successfully used GUI Easy on small
and large GUI projects. We report on our experience constructing and
using GUI Easy and derive from that experience several architectural
patterns and principles for building functional programs out of
imperative systems

<iframe width="560" height="315" src="https://www.youtube.com/embed/xNPTwlQPmno?si=Ra_jmuTOHqGhevjV" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

### [Phases in Software Architecture](https://www.cs.ox.ac.uk/publications/publication15860-abstract.html)
#### Jeremy Gibbons, Oisín Kidney, Tom Schrijvers, Nicolas Wu

The large-scale structure of executing a computation can often be
thought of as being separated into distinct phases. But the most
natural form in which to specify that computation may well have a
different and conflicting structure. For example, the computation
might consist of gathering data from some locations, processing it,
then distributing the results back to the same locations; it may be
executed in three phases—gather, process, distribute—but mostly
conveniently specified orthogonally—by location. We have recently
shown that this multi-phase structure can be expressed as a novel
applicative functor (also known as an idiom, or lax monoidal
functor). Here we summarize the idea from the perspective of software
architecture. At the end, we speculate about applications to
choreography and multi-tier architecture.

<iframe width="560" height="315" src="https://www.youtube.com/embed/zh2pM6dOjyM?si=bzfGm4WZ2gxuoJXU" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

### [Stretching the Glasgow Haskell Compiler](https://dl.acm.org/doi/10.1145/3609025.3609476?cid=99660990042)
#### Jeffrey M. Young, Sylvain Henry, John Ericson

Over the last decade Haskell has been productized; transitioning
from a research language to an industrial strength language ready for
large-scale systems. However, the literature on architecting such
systems with a pure functional language is scarce. In this paper we
contribute to that discourse, by using a large-scale system: the
Glasgow Haskell Compiler (GHC) itself, as a guide to more main-
tainable, flexible and effective pure functional software
architectures. We describe, from experience working on GHC, how GHC as
a system, violates the desirable properties that make pure
functional programming attractive: immutability, modularity, and
composability. With these violations identified, we provide actionable
guidance for other functional system architectures; drawing heavily on
domain-driven design. We write this paper from an engineering
perspective, with the hope that our collection and recapitulation may
provide insight into future best practices for other pure functional
software architects.

<iframe width="560" height="315" src="https://www.youtube.com/embed/vkC1AixG5EQ?si=1ugQcjRulJBunHfF" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

### [Typed Design Patterns for the Functional Era](https://dl.acm.org/doi/10.1145/3609025.3609477)
#### Will Crichton

This paper explores how design patterns could be revisited in the era
of mainstream functional programming languages. I discuss the kinds of
knowledge that ought to be represented as functional design patterns:
architectural concepts that are relatively self-contained, but whose
entirety cannot be represented as a language-level abstraction. I
present four concrete examples embodying this idea: the Witness, the
State Machine, the Parallel Lists, and the Registry. Each pattern is
implemented in Rust to demonstrate how careful use of a sophisticated
type system can better model each domain construct and thereby catch
user mistakes at compile-time.

<iframe width="560" height="315" src="https://www.youtube.com/embed/mB2ZhK8tB8Y?si=MtYDeAcURhlNu-3B" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

### [Types that Change: The Extensible Type Design Pattern](https://ivanperez.io/#typesthatchange)
#### Ivan Perez

Compilers are often structured as chains of transformations, from
source code to object code, through multiple intermediate repre-
sentations. The existence of different representations of the same
program presents challenges both for code maintenance and in terms of
architecture. The types used to capture programs at multiple stages
may be similar but not interchangeable, leading to code
duplication. Methods to alleviate such duplication often lead to
violations of software engineering principles of abstraction and
encapsulation. This pearl discusses a design pattern where an
algebraic data type (ADT) is extended with an argument type function that
is applied to every component of the ADT. The resulting parametric
type can be instantiated with multiple type functions, each providing
a different feature. We demonstrate the versatility of this pattern by
capturing notions of traceability and error recovery, and demonstrate
that it can also be used to selectively modify existing types, as well
as to extend them. Our proposal has been validated by applying it to a
real-world use case with very good results.

<iframe width="560" height="315" src="https://www.youtube.com/embed/JTZUgLy-r18?si=xAHck1NNx8onhMix" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
