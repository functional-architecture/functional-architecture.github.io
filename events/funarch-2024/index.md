---
layout: page
title: FUNARCH 2024
description: The Second ACM SIGPLAN Workshop on Functional Software Architecture - FP in the Large
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
    
FUNARCH 2024 will be co-colocated with [ICFP 2024](https://icfp24.sigplan.org/)
in Milan on September 6th 2024.

News is available on [Mastodon](https://discuss.systems/@funarch),
[Bluesky](https://bsky.app/profile/funarch.bsky.social), and
[Twitter](https://twitter.com/ACMFUNARCH).

## Code of Conduct

FUNARCH adheres to the [SIGPLAN/ICFP Code of Conduct](https://icfp24.sigplan.org/attending/code-of-conduct).

## Program

### Architecting Functional Programs
#### [Marco Sampellegrini](https://marcosampellegrini.com/)
##### (Keynote)

Functional programming in the small works great. Things start to get
shaky when there are many services and teams involved, something that
is becoming more and more common with large distributed systems.

The value of the tools we know and love, like static typing and
powerful type systems, decreases as the system gets larger and the
number of components involved increases. In an industry that often
praises fast paced releases (the ultimate startup motto: ship fast or
die trying), this becomes even more problematic.

How do we get to enforce correctness and reap the benefits of FP, when
we can't statically check the entire system? When we have to cross the
boundaries of a single compilation unit? Our beautifully crafted types
aren't going to cut it.

This is where Software Architecture comes in. A well architected
system is not some stroke of genius: often the opposite. Good software
architecture means you still get to reason about the whole thing and
make changes to separate components without affecting others. While we
can afford some complexity in the small (ie. fancy types), complexity
in the large can break a project. As much as we wish we could solve
these issues with static typing or formal verification, part of the
solution is definitely non-technical. Conversations among all parties
involved (yes, business people included) are key for good architecture
to emerge.

We'll talk about what I found to be the more effective techniques to
architecture such large systems: event sourcing, cqrs and the over
arching philosophy of Domain Driven Design.

## F3: A Compiler For Feature Engineering
#### Weixi Ma, Arnaud Venet, Junhua Gu, Subbu Subramanian, Siyu	Wang, Rocky Liu (Meta)
#### Daniel Friedman, Yafei	Yang (Indiana University)

In the practices of machine learning, Feature Engineering is a crucial
step that converts raw data to the inputs of models. This process
conventionally relies on data processing languages (typically SQL) and
now sees arising challenges from the advancement of machine learning
techniques. We present the design of F3, a DSL and a compiler
developed at Meta. We show how F3 transforms the inspirations from
functional programming and type theory to an industrial grade software
architecture that empowers a platform that serves billions of users.

## Design and implementation of a verified interpreter for additive manufacturing programs
#### Matthew Sottile, Mohit Tekriwal (Lawrence Livermore National Laboratory)
##### (Experience report)

This paper describes the design of a verified tool for analyzing tool
paths defined in the RS-274 language for 3d printing systems. We
describe how the analyzer was designed to allow a mixture of
verification and code-extraction techniques to be combined for
constructing a correct toolpath analyzer written in the OCaml
language. We show how we moved from a fully hand-written OCaml program
to one incorporating verified components, highlighting architectural
decisions that were made to facilitate this process. Finally, we share
a set of architectural lessons that are generally applicable to other
software with a similar goal of integration of verified components.

## Applying Continuous Formal Methods to Cardano
#### [James Chapman](http://www.cs.ioc.ee/~james), Arnaud Bailly, Polina Vinogradova (IOHK)
##### (Experience Report)

Cardano is a Proof-of-Stake cryptocurrency with a market cap in the
tens of billions of USD and a daily volume of hundreds of millions of
USD. In this paper we reflect on applying formal methods, functional
architecture and Haskell to building Cardano. We describe our
strategy, our projects, reflect on lessons learned, the challenges we
face and how we propose to meet them.

## Continuations: what have they ever done for us?
#### [Marc Kaufmann](https://trichotomy.xyz/) (Austriae	Central European University), [Bogdan Popa](https://defn.io/)
##### (Experience Report)

Surveys and experiments in economics involve stateful interactions:
participants receive different messages based on earlier
answers,choices, and performance, or trade across many rounds with
other participants. In the design of Congame, a platform for running
such economic studies, we decided to use delimited continuations to
manage the common flow of participants through a study. Here we report
on the positives of this approach, as well as some challenges of using
continuations, such as persisting data across requests, working with
dynamic variables, avoiding memory leaks, and the difficulty of
debugging continuations. 


## Bidirectional Data Transformations
#### Marcus Crestani, Markus Schlegel, Marco Schneider (Active Group)

Data structures are the foundation of software. Different components
of a system may need the same information but may have different
demands on its structure for reasons of performance, resource
efficiency, technical constraints, convenience, and so on. For
instance, transmitting data over a network requires a format that is
suitable for serialization, while persisting data requires a format
that is more suitable for storage. Thus, programmers need to translate
data between several data structures and formats all the
time. Authoring these translations manually is a lot of work because
programmers need to implement the logic twice, once for each
direction. This is redundant, tedious, and error-prone, and a case of
low coherence. We show how using bidirectional data transformations
that use functional optics like lenses and projections simplify the
conversions. These ideas and techniques make converting data simple
and straightforward and foster understanding of the relationship
between data structures by explicitly describing their connections in
a composable manner.

[Download](https://dl.acm.org/doi/10.1145/3677998.3678224?cid=99661323233)

## Program Chairs

- [Mike Sperber](https://www.deinprogramm.de/sperber/) (Active Group, Germany)
- [Perdita Stevens](https://www.inf.ed.ac.uk/people/staff/Perdita_Stevens.html)
  (University of Edinburgh, UK)

## Program Committee

- [Annette Bieniusa](https://softech.informatik.uni-kl.de/team/annettebieniusa)
  (University of Kaiserslautern)
- Jeffrey Young (IOG)
- [Will Crichton](https://willcrichton.net/)
  (Brown University)
- Isabella Stilkerich (Schaeffler Technologies AG)
- [Kiko Fernandez-Reyes](https://www.plresearcher.com/) (Ericsson)
- [Ryan Scott](https://ryanglscott.github.io/about/) (Galois)
- [Satnam Singh](https://raintown.org/satnam/) (Groq)
- [Facundo Dominguez](https://github.com/facundominguez) (Tweag)
- [Ilya Sergey](https://ilyasergey.net/) (University of Singapore)
- [Martin Elsman](http://elsman.com/) (University of Copenhagen)
- [Benjamin Pierce](https://www.cis.upenn.edu/~bcpierce/)
  (University of Pennsylvania)
- [Matthew Flatt](https://users.cs.utah.edu/~mflatt/)
  (University of Utah)
- [Nada Amin](https://namin.seas.harvard.edu/)
  (Harvard University)
- [Richard Eisenberg](https://richarde.dev/) (Jane Street)
