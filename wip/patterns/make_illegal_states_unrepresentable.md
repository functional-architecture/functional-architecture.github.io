"Make illegal states unrepresentable" is a mantra commonly used in
functional programming with static types (OCaml, Haskell, Scala,
etc). The idea is to model data representations in such a way that
nonsensical ("illegal") values ("states") are inexpressible
("unrepresentable").

The term "Make illegal states unrepresentable" was coined by Yaron
Minsky in a 2010 guest lecture at Harvard. Ron never fully explained
what "Make illegal states unrepresentable" means, but [his
example](https://blog.janestreet.com/effective-ml-revisited/) is quite
illuminating in its own right.

Minsky starts off with the following OCaml code as an example of bad
data modelling.

```ocaml
type connection_state =
| Connecting
| Connected
| Disconnected

type connection_info = {
  state: connection_state;
  server: Inet_addr.t;
  last_ping_time: Time.t option;
  last_ping_id: int option;
  session_id: string option;
  when_initiated: Time.t option;
  when_disconnected: Time.t option;
}
```

Some illegal states can be represented. For example, we can come up
with a `Connecting` state that has a `when_disconnected` value.

```ocaml
let illegal_1 = {
  state = Connecting;
  when_disconnected = Some some_time;
  ...
}
```

Or we can come up with a `Connected` state that has a `last_ping_time`
but no `last_ping_id`.

```ocaml
let illegal_2 = {
  state = Connected;
  last_ping_time = Some some_time;
  last_ping_id = None;
  ...
}
```

In essence, for the data model above, there are some invariants that
aren't captured by the model, so they have to be adhered to by users
of the model. The invariants have to be described outside of the
programming language facilities, for instance in a comment. These
descriptions can therefore get out of sync with the code. Since the
invariants aren't machine checked they are a common source of bugs.

An improved model that inherently expresses relevant invariants looks like this:

```ocaml
type connecting = { when_initiated: Time.t; }
type connected = { last_ping : (Time.t * int) option;
          session_id: string; }
type disconnected = { when_disconnected: Time.t; }

type connection_state =
| Connecting of connecting
| Connected of connected
| Disconnected of disconnected

type connection_info = {
  state : connection_state;
  server: Inet_addr.t;
}
```

Now `connection_state` is a proper sum-of-products. The fields that
only make sense for one of the three states are now part of the
corresponding type only. The field `server` makes sense for all states
and is therefore part of the larger `connection_info`
type. Additionally, the requirement that `last_ping_time` and
`last_ping_id` are either both `Some ...` or both `None` is now
expressed by `last_ping` being a single option of a tuple.

## Applicability to other programming paradigms

"Make illegal states unrepresentable" was invented in the context of
OCaml, which is a functional programming language with a strong static
type system, but the mantra is applicable to most other programming
paradigms. For example the Rust community adopted the mantra. Rust has
a strong static type system but isn't a functional language. On the
other hand, Clojure – a dynamically typed functional language – also
allows programmers to make illegal states unrepresentable. 

### Rust

This [blog post](https://corrode.dev/blog/illegal-state/) discusses
"Make illegal states unrepresentable" in the context of Rust.

### Clojure

Minsky's original example suggests that "Make illegal states
unrepresentable" is about algebraic data types and static type
checking. Clojure doesn't support either of these features, but we can
still make illegal states unrepresentable. The original example translated to Clojure would look like this:

```clojure
TODO
```

## Illegal states vs. illegal values

"Make illegal states unrepresentable" specifically mentions
"states". In software engineering, "state" usually refers to mutable
state, but Ron Minsky's original examples illustrate that in this
context "state" has a different notion. His `connection_state`
describes immutable values. The term "state" hints at the idea that
these values are parts of a state machine. `connection_state` most
likely moves from `Connecting ...` to `Connected ...` to `Disconnected ...`.

"Make illegal states unrepresentable" is applicable to use cases apart
from state machines. A better term would be "Make illegal values
unrepresentable". In addition to values created with sums and
products, the latter would include functions, since functions are
values in functional programming. The idea of "Make illegal values
unrepresentable" would then be equivalent to programming with
machine-checked specifications. Examples of the latter are [How to
Keep Your Neighbours in
Order](https://personal.cis.strath.ac.uk/conor.mcbride/Pivotal.pdf) by
Conor McBride and [Symbolic and Automatic Differentiation of
Languages](http://conal.net/papers/language-derivatives/) by Conal
Elliott.
