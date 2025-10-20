---
layout: page
title: FUNARCH 2025
img: assets/img/funarch-logo.jpg
---

## The Third ACM SIGPLAN Workshop on Functional Software Architecture - FP in the Large

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

FUNARCH 2025 will be co-located with [ICFP 2025](https://icfp25.sigplan.org/)
in Singapore on October 17th 2025.

News is available on [Mastodon](https://discuss.systems/@funarch),
[Bluesky](https://bsky.app/profile/funarch.bsky.social), and
[Twitter](https://twitter.com/ACMFUNARCH).

## Call for Participation

The [CFP is open.]({{call_for_participation}})

## Call for Lightning Talks

The [CFL is open.](https://conf.researchr.org/home/icfp-splash-2025/funarch-2025#Call-for-lightning-talks)

## Proceedings

... are available from the [ACM Digital Library](https://dl.acm.org/doi/proceedings/10.1145/3759163).


## Code of Conduct

FUNARCH adheres to the [SIGPLAN/ICFP Code of Conduct](https://icfp24.sigplan.org/attending/code-of-conduct).

This years videos will be available as a YouTube playlist; just like [last year's](https://www.youtube.com/playlist?list=PLyrlk8Xaylp6KYpIQg94J6vpyTW9x1Qe7).

## Accepted Papers and Talks

<!-- ## [A Layered Certifying Compiler Architecture](todo) -->
## A Layered Certifying Compiler Architecture
#### Jacco Krijnen, Wouter Swierstra, Gabriele Keller (Utrecht University)
#### Manuel Chakravarty (Tweag & IOG), Joris Dral (Well-Typed),

The formal verification of an optimising compiler for a realistic programming
language is no small task. Most verification efforts develop the compiler and
its correctness proof hand in hand. Unfortunately, this approach is less
suitable for today’s constantly evolving community-developed open-source
compilers and languages. This paper discusses an alternative approach to
high-assurance compilers, where a separate certifier uses translation validation
to assess and certify the correctness of each individual compiler run. It also
demonstrates that an incremental, layered architecture for the certifier
improves assurance step-by-step and may be developed largely independently from
the constantly changing main compiler code base. This approach to compiler
correctness is practical, as witnessed by the development of a certifier for the
deployed, in-production compiler for the Plutus smart contract
language. Furthermore, this paper demonstrates that the use of functional
languages in the compiler and proof assistant has a clear benefit: it becomes
straightforward to integrate the certifier as an additional check in the
compiler itself, leveraging the the Rocq proof assistant’s program extraction.

<!-- TODO: -->
<!-- <iframe width="560" height="315" src="https://www.youtube.com/embed/1NgrEH0RUAw?si=5JcKyyoiuskQiANM" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe> -->

<!-- ## [Evolution of Functional UI Paradigms](todo) -->
## Evolution of Functional UI Paradigms
#### Michael Sperber, Markus Schlegel (Active Group GmbH)

Functional paradigms for user-interface (UI) programming have undergone
significant evolution over the years, from early stream-based approaches,
monad-based toolkits mimicking OO practice to modern model-view-update
frameworks. Changing from the inherently imperative classic
Model-View-Controller pattern to functional approaches has significant
architectural impact, drastically reducing coupling and improving
maintainability and testability. On the other hand, achieving good modularity
with functional approaches is an ongoing challenge. This paper traces the
evolution of functional UI toolkits along with the architectural implications of
their designs (including two of our own), summarizes the current state of the
art and discusses remaining issues.

<!-- TODO: -->
<!-- <iframe width="560" height="315" src="https://www.youtube.com/embed/NFQBTJ0ASyE?si=TtatCVTgI_I3oDaM" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe> -->

<!-- ## [Six Years of FUNAR: Functional Training for Software Architects](todo) -->
## Six Years of FUNAR: Functional Training for Software Architects
#### Michael Sperber
##### (Experience Report)

Since 2019, the International Software Architecture Qualification board has
featured a three-day curriculum for Functional Software Architecture as part of
its Advanced Level certification program. We have taught more than 30 trainings
based on this curriculum, mostly to audiences with little or no exposure to
functional programming. This paper reports on our experience, and how content
and delivery of the training has evolved over the past four years.

<!-- TODO: -->
<!-- <iframe width="560" height="315" src="https://www.youtube.com/embed/uZGckHd8yW4?si=ar-1gFzUzwrW9kB4" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe> -->

<!-- TODO: Lightning Talks -->


## Program Chairs
- Jeffrey Young (Epic Games)
- [Cristine Rizkallah](https://people.eng.unimelb.edu.au/rizkallahc/) (University of Melbourne)

## Program Committee
- Isabella	Stilkerich (Schaeffler Technologies)
- [Ryan	Scott](https://ryanglscott.github.io/about/) (Galois)
- [Facundo	Dominguez](https://github.com/facundominguez) (Tweag)
- [J. Garrett	Morris](https://cs.uiowa.edu/people/garrett-morris) (University of Iowa)
- [Nada	Amin](https://namin.seas.harvard.edu/) (Harvard University)
- Tom	Ellis (Groq)
- [KC	Sivaramakrishnan](https://kcsrk.info/) (IIT Madras and Tarides)
- [Hidehiko	Masuhara](https://prg.is.titech.ac.jp/people/masuhara/) (Institute of Science Tokyo)
