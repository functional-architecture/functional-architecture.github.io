"Make illegal states unrepresentable" is a mantra commonly used in
functional modeling. The idea is to model data representations in such
a way that nonsensical ("illegal") values ("states") are inexpressible
("unrepresentable").

## Introduction

The term "Make illegal states unrepresentable" was coined by Yaron
Minsky in a 2010 guest lecture at Harvard. Ron never fully explained
what the mantra means, but [his example](https://blog.janestreet.com/effective-ml-revisited/)
is quite illuminating in its own right.

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

With this representation some illegal states can be represented. For
example, we can come up with a `Connecting` state that has a
`when_disconnected` value.

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

In this representation there are some invariants that aren't captured
by the model, so they have to be adhered to by users of the model,
which introduces implicit coupling. The invariants have to be
described outside of the programming language facilities, for instance
in a comment. These descriptions can get out of sync with
the code. Since the invariants aren't machine checked they are a
common source of bugs.

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

## Common techniques

The example above – transforming a product type (`connection_info`)
with many nullable fields into a sum type with less nullable fields –
demonstrates one effective technique to make illegal states
unrepresentable. There are others, such as using associative maps and
functions. Take a Scala representation of time series as a list of
time-double-tuples:

```scala
object TimeSeriesService {
  type TimeSeries = List[(Time, Double)]
}
```

This allows for illegal and nonsensical values to be represented:

```scala
// Let t1, t2, t3 be timestamps with t1 < t2 < t3
val ts1 = List((t2, 6.5), (t1, 5.0), (t3, 7.3))
val ts2 = List((t1, 6.5), (t1, 6.5))
val ts3 = List((t1, 6.5), (t1, 13.4))
```

`ts3` is certainly illegal, and `ts1` and `ts2` are surely not the
common case either. A user of the `TimeSeriesService` now has to think
hard about what each these cases denote. A more straightforward model
is to represent time series as associative maps from time to double:

```scala
object TimeSeriesService {
  type TimeSeries = Map[Time, Double]
}
```

Now contradictory or redundant values are inexpressible. An even
better model is time series as functions from time to optional
double:

```scala
sealed trait TS extends Function1[Time, Option[Double]]

object TimeSeriesService {
  type TimeSeries = TS
}
```

This way, time series can be represented by lists, maps, proper
functions, static values, etc, as long as we can make these types
behave like a function:

```scala
class TSList(list: List[(Time, Option[Double])])
    extends TS {

  def apply(t: Time): Option[Double] =
    list.find( (tx, _) => tx == t ).flatMap(_._2)
}

class TSConst(val: Double) extends TS {
  def apply(_: Time): Option[Double] =
    Some(val)
}
```

With this model of time series as functions we made illegal states
unrepresentable and also we made all legal states representable.

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

Minsky's original talk suggests that "Make illegal states
unrepresentable" is about algebraic data types and compile-time type
checking. The underlying ideas are applicable to dynamically typed
languages such as Clojure (+
[active-clojure](https://github.com/active-group/active-clojure)
records) as well, as is witnessed by the following contrasting pair of
data representations.

The bad representation uses a flat record as in the OCaml code above:

```clojure
(define-record-type ConnectionInfo
  make-connection-info
  connection-info?
  [state connection-info-state ;; one of :connecting, :connected, :disconnected
   server connection-info-server ;; non-nullable
   last-ping-time connection-info-last-ping-time ;; nullable
   last-ping-id connection-info-last-ping-id ;; nullable
   session-id connection-info-session-id ;; nullable
   when-initiated connection-info-when-initiated ;; nullable
   when-disconnected connection-info-when-disconnected ;; nullable
   ])
```

This, again, allows for nonsensical values to be representable:

```clojure
(def illegal-1
  (make-connection-info
   ;; connection-state
   :connecting
   ...
   ;; when-disconnected
   some-date))

(def illegal-2
  (make-connection-info
   ;; connection-state
   :connected
   ...
   ;; last-ping-time
   some-date
   ;; last-ping-id
   nil
   ...
   ))
```

A better representation looks quite similar to the improved OCaml code above:

```clojure
(define-record-type Connecting
  ^:private mk-connecting
  connecting?
  [when connecting-when])

(defn make-connecting [when]
  (assert (date? when))
  (mk-connecting when))

(define-record-type Connected
  ^:private mk-connected
  connected?
  [last-ping connected-last-ping
   session-id connected-session-id])

(define-record-type Ping
  make-ping
  ping?
  [when ping-when
   id ping-id])

(defn make-connected [last-ping session-id]
  (assert (ping? last-ping))
  (assert (session-id? session-id))
  (mk-connected last-ping session-id))

(define-record-type Disconnected
  ^:private mk-disconnected
  disconnected?
  [when disconnected-when])

(defn make-disconnected [when]
  (assert (date? when))
  (mk-disconnected when))

(defn connection-state? [x]
  (or (connecting? x)
      (connected? x)
      (disconnected? x))

(define-record-type ConnectionInfo
  ^:private mk-connection-info
  connection-info?
  [state connection-info-state
   server connection-info-server])

(defn make-connection-info [state server]
  (assert (connection-state? state))
  (assert (inet-addr? server))
  (mk-connection-info state server))
```

Since Clojure doesn't do proper static type checking, the smart
constructor `make-connection-info` above can only check its parameters
at runtime via `assert`. Still, this latter representation is
preferable to the previous one for the same reasons as in the original
OCaml example.

## Discussion: Illegal states vs. illegal values

"Make illegal states unrepresentable" specifically mentions
"states". In software engineering, "state" usually refers to mutable
state, but Ron Minsky's original example illustrates that in this
context "state" has a different notion. His `connection_state`
describes immutable values. The term "state" hints at the idea that
these values are parts of a state machine. `connection_state` most
likely moves from `Connecting ...` via `Connected ...` to `Disconnected ...`.

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
