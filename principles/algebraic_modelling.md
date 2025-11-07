Algebraic modelling or algebra-driven design allows software developers to focus
on the design and understanding of the problem instead of technical details of
implementations or incidental complexity.  By looking for and recognizing
well-known mathematical properties within the problem to solve when designing a
solution, powerful abstractions emerge without having to reinvent the wheel.

Typical properties to look for include Associativity, Identity, Idempotency,
Invertibility, Distributivity, Commuatativity, and Annihilation.  Certain
combinations of properties form algebaric structures like Semigroups, Monoids,
Groups, Semilattices, Functors, Applicative Functors, and Monads.

All these properties and structures are exceptionally well-studied mathematical
objects that therefore come with a deep understanding. And the unreasonable
effectiveness of mathematics makes them graspable and relatable by humans.

Since mathematical structures are universal patterns of composition, these
structures foster reusability and composability and can be reliably shared with
others.  And what you are sharing is all the knowledge and fundamental
understanding of the problem, not just implementations.

Developing models can be done computer-aided by using theorem provers to make
sure that the properties combine in a sensical way. And once the model is done,
deriving an actual implementation is straight-forward because the up-front
design already yielded a beautiful solution.  Additionally, already existing
libraries and algorithms for the well-known mathematical objects can shoulder
the implementation.

Algebraic modelling leads to perfect abstractions on top of sound mathematics.
