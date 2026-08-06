---
layout: page
title: FUNARCH 2026
img: assets/img/funarch-logo.jpg
---

## The Fourth ACM SIGPLAN Workshop on Functional Software Architecture - FP in the Large

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

FUNARCH 2026 will be co-located with [ICFP 2026](https://icfp26.sigplan.org/)
in Indianapolis, Indiana on August 29, 2026.

News is available on [Mastodon](https://discuss.systems/@funarch),
[Bluesky](https://bsky.app/profile/funarch.bsky.social), and
[Twitter](https://twitter.com/ACMFUNARCH).

## Call for Papers

The [CFP is open.](https://icfp26.sigplan.org/home/funarch-2026#Call-for-Papers)

## Call for Lightning Talks

The [CFL is open.](https://icfp26.sigplan.org/home/funarch-2026#Call-for-Lightning-Talks)

## Proceedings

TBD
<!-- Are available from the [ACM Digital Library](https://dl.acm.org/doi/proceedings/10.1145/3759163). -->


## Code of Conduct

FUNARCH adheres to the [SIGPLAN/ICFP Code of Conduct](https://icfp26.sigplan.org/attending/code-of-conduct).

This years videos will be available as a YouTube playlist; just like [last year's](https://www.youtube.com/playlist?list=PLyrlk8Xaylp6KYpIQg94J6vpyTW9x1Qe7).

## Accepted Papers and Talks


## Functional Mechanical Sympathy
<!-- TODO: add proceedings link (https://dl.acm.org/doi/10.1145/3759163.3760427) -->
#### Richard Feldman (Zed Industries Inc.)

For the first time in decades, the two fastest-growing mainstream programming
languages are not object-oriented. They are statically typed, with first-class
lambdas, and are known for their concurrency stories. They are Go and Rust, both
imperative.

If object orientation is no longer a requirement for mainstream adoption, and
lambdas have become commonplace, why aren't two functional languages the
fastest-growing? One selling point that makes Go and Rust stand out is
performance. Go offers solid runtime performance and garbage collection, while
Rust offers substantially more performance, but at the cost of substantially
higher language complexity and build times.

Their growing popularity can't be explained by paradigm familiarity alone. The
most popular modern JavaScript build tools are written in Go and Rust, often by
programmers who enthusiastically practiced a functional style in their
TypeScript code bases before learning Go or Rust specifically in order to get
the performance they needed. Even though they liked FP, they couldn't find a way
to achieve their performance goals with it.

In many cases, the performance of functional programs comes down to
architecture. Some architectures are better-suited than others to patterns of
processor and memory usage that run fast on modern hardware. In any domain where
performance is more than a nice-to-have, the correctness and comprehensibility
benefits of a functional architecture will be weighed against the runtime
performance of the programs it produces.

This talk will dive into the intersection of functional programming and
mechanical sympathy: how we can achieve faster-performing functional programs by
architecting with the machine in mind.

<!-- TODO: video <iframe width="560" height="315" src="https://www.youtube.com/embed/FB0CS0X1QRc?si=1ADvA6Mlb92AjNZm" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe> -->


## From Lambda to Ledger: An Architectural Comparison of Plinth and Plutarch
<!-- TODO: (https://dl.acm.org/doi/10.1145/3759163.3760427) -->
#### Seungheon Oh, Ziyang Liu (IOG), Philip Wadler (IOG; University of Edinburgh)

Plinth and Plutarch are two languages for writing smart contracts on the Cardano
blockchain. Both are based on Haskell, have been used in production over the
past few years, and share the same host ecosystem and compilation target.
However, they have strikingly different architectures: Plinth compiles a subset
of Haskell through deep integration with GHC, while Plutarch represents its
programs as explicitly constructed typed terms embedded within Haskell. These
choices lead to different balances between abstraction and performance, reuse
and specialization, and user experience and implementation effort.

This paper presents an architectural comparison of these two approaches,
grounded in the authors' experience implementing and using both languages. We
analyze their design trade-offs across multiple dimensions, and present an
empirical evaluation on real-world programs, examining how architectural choices
affect source code, generated target code, and compiler error messages. Our
comparison offers broader insights for language design, both within and beyond
the blockchain domain.

<!-- TODO: video <iframe width="560" height="315" src="https://www.youtube.com/embed/FB0CS0X1QRc?si=1ADvA6Mlb92AjNZm" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe> -->

## Evolution of Functional UI Paradigms
<!-- TODO: (https://dl.acm.org/doi/10.1145/3759163.3760429) -->
#### Michael Sperber (Active Group GmbH)
##### (Experience Report)

We have been developing a distributed application called Lokalisierung using
functional programming since 2015. Lokalisierung automatically configures
mobiles devices in an a large organization of car-inspection shops. It uses
peer-to-peer synchronization to distribute configuration data among the devices,
without the use of a central server. This paper describes the original design
and evolution of the system. Specifically, we highlight how the event-based
architecture supports synchronization but also enables flexibility for changes
after the original rollout such as undoing configuration changes, and database
thinning. We also reflect on design and implementation mistakes we made during
its 10-year development.

<!-- TODO: <iframe width="560" height="315" src="https://www.youtube.com/embed/_HDkqG28yzw?si=qqaCLRlBsNCqZRzk" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe> -->

## Functional State Machines in Rust: Typestate and Newtype Patterns (Experience Report)
<!-- TODO: (https://dl.acm.org/doi/10.1145/3759163.3760428) -->
#### Leon Heuer (NORDAKADEMIE gAG Hochschule der Wirtschaft), Falk Woldmann Lu (Otto GmbH & Co. KGaA), Jan Haase (NORDAKADEMIE gAG Hochschule der Wirtschaft)
##### (Experience Report)

We investigate the effects on code quality of the design patterns typestate and
newtype in the language Rust, by conducting three case studies from production
code, evaluated through expert interviews, static code analysis and benchmarks.
The findings indicate that: (1) Typestate improves code faultlessness and
testability, but comes at the cost of more boilerplate code and can degrade
readability. Code with extensive branching logic and many invariants likely
benefits most from the pattern. (2) Newtype combined with the “Parse, don’t
validate” principle improves code quality at a low cost and prevents invalid
states at runtime.

<!-- TODO: <iframe width="560" height="315" src="https://www.youtube.com/embed/EKqM-EjrRkg?si=PyHVUZRRrbceUc8n" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe> -->

## Lightning Talks

TBD

<!-- ## Bluefin in Industry -->
<!-- #### Tom Ellis -->
<!-- ##### (Experience Report) -->
<!-- This short talk will recount our experience using the Bluefin effect system for -->
<!-- Haskell, to replace transformers and MTL-style in the design of assembly tooling -->
<!-- for Groq’s LPU chip. -->


<!-- <iframe width="560" height="315" src="https://www.youtube.com/embed/0ABhsBpcxvY?si=HSZAYfvq6YvD0rAx" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe> -->

<!-- ## What Could Functional Architecture Mean -->
<!-- #### Jeffrey Young -->
<!-- Software Architecture itself is nebulously defined. So then what are we to make -->
<!-- of Functional Architecture? In this short talk I’ll wildy speculate about -->
<!-- possible definitions. -->

<!-- <iframe width="560" height="315" src="https://www.youtube.com/embed/x8jLOtZoOOU?si=74EMYnUB1seGhv_l" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe> -->

<!-- ## The Future of FUNARCH -->
<!-- #### Jeffrey Young -->
<!-- This talk is the yearly recap and retrospective of the FUNARCH workshop. -->

<!-- <iframe width="560" height="315" src="https://www.youtube.com/embed/mBTUuHY4ylI?si=pjUeKffIt1-oCLI8" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe> -->

## Program Chairs
- [Jeffrey Young](https://pure-systems.org) (Canonical)
- [Nicolas Wu](https://profiles.imperial.ac.uk/n.wu/) (Imperial College London)

## Program Committee
- Christiaan Baaij (QBayLogic)
- [Laurent P. René de Cotret](https://laurentrdc.xyz/index.html) (Bitnomial)
- [Facundo	Dominguez](https://github.com/facundominguez) (Tweag)
- [J. Garrett	Morris](https://cs.uiowa.edu/people/garrett-morris) (University of Iowa)
- [Ryan	Scott](https://ryanglscott.github.io/about/) (Galois)
- Isabella	Stilkerich (Schaeffler Technologies)
- [Katsuhiro Ueno](https://www.pllab.ie.niigata-u.ac.jp/katsu/) (Niigata University)
