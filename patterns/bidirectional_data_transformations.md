Structured data is the foundation of software.  Different components
of a system may need the same information but may have different
demands on its structure for reasons of performance, resource
efficiency, technical constraints, convenience, and so on. For
instance, transmitting data over a network requires a format that is
suitable for serialization, while persisting data requires a format
that is more suitable for storage.  Thus, programmers need to
translate data between several data structures and formats all the
time. Authoring these translations manually is a lot of work because
programmers need to implement the logic twice, once for each
direction.  This is redundant, tedious, and error-prone, and a case of
low coherence.  Bidirectional data transformations that use functional
optics like lenses and projections simplify these conversions and
foster understanding of the relationship between data structures by
explicitly describing their connections in a composable manner.

See [the paper by Crestani et al.](https://dl.acm.org/doi/10.1145/3677998.3678224) for an introduction to Bidirectional Data Transformations.


## When to reach for this pattern

TODO

## When _not_ to reach for this pattern

TODO

## Functional optics libraries

The mechanical parts of this pattern can be expressed in library code.
All functional programming languages come with well-engineered
libraries for lenses, prisms etc.

### Clojure(Script)

The [active-clojure](https://github.com/active-group/active-clojure)
library comes with `active.clojure.lens` namespace for lens primitives
and combinators. These lenses are well integrated with
`active.clojure.record`. Any record field accessor defined with
`define-record-type` is also a valid lens. The following listing
defines two record types `URL` and `Link` and a lens `link-host` that
composes the lenses `link-url` and `url-host`.

```clojure
(define-record-type URL
  make-url
  url?
  [protocol url-protocol
   host url-host
   port url-port
   path url-path])
   
(define-record-type Link
  {:projection-lens-constructor make-link-lens}
  make-link
  link?
  [description link-description
   url link-url])
   
(def link-host (lens/>> link-url url-host))
```

### Haskell

For Haskell there's the widely used [`lens` package](https://hackage.haskell.org/package/lens). An alternative is [Optics](https://hackage.haskell.org/package/optics-0.4.2.1/docs/Optics.html) which is based on different design choices that are best described by the section [Comparison with `lens`](https://hackage.haskell.org/package/optics-0.4.2.1/docs/Optics.html#g:4).

### Scala

The de-facto standard lens library in Scala is called [Monocle](https://www.optics.dev/Monocle/).

### F#

[Aether](https://xyncro.tech/aether/) is an Optics library for F#, similar to the Haskell [`lens` package](https://hackage.haskell.org/package/lens).

### OCaml

[OCamlverse](http://ocamlverse.net) mentions [two libraries for lenses in OCaml](http://ocamlverse.net/content/lenses.html):

* [ocaml-lens](https://github.com/avsm/ocaml-lens)
* [Accessor](https://github.com/janestreet/accessor) by JaneStreet.

### Erlang/Elixir

TODO
