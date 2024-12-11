Functional core, imperative shell is a pattern that structures software into two
basic parts:

- The part that only depends on the inputs to produce the
  desired output -- the pure functions -- and

- the part that handles the interactions with the outside world -- impure
  functions that handle the statefule infrastructure.

The typical visualization shows a big functional core where all the pure
functions live, and a thin functional shell where the impure functions interface
with the outside world:

![Functional core, imperative shell](functional_core_imperative_shell.png)

The domain logic -- *what* the software does -- is part of the functional core.
The lack of side-effects and infrastructure makes the functions of the core
easily testable since there is no need to bring up parts of the infrastructure
or manage state for testing.

The imperative shell orchestrates all the impure effects that a software needs
to be able to interact with the outside world.  It takes inputs from the
external world (e.g., user input, network requests) and orchestrates how those
inputs flow into the functional core. It then takes the results from the core
and applies side effects, such as writing to a database or sending a response
back to the user.  In the shell, the programs can handle all the impure
interactions and take care of errors, non-deterministic behaviour, and
exceptions in concert.  The functions in the shell call the functions in the
core with the pure values obtained from the impure interactions.  The functions
in the core never call the shell.  Separating into shell and core is always
possible: Every function can be refactored into parts that supply input or
process output impurely and the parts that turn input into output purely.

This pattern brings about a separation of concerns between pure and impure
functions.  It collects the infrastructure's technical details in the shell
which decouples them from the pure domain logic which allows parts of the
infrastructure to be easily updated or swapped out without touching the pure
logic.

## Shortcomings

This pattern does not necessarily lead to a separation of concerns between
domain logic and infrastructure since the usage of infrastructure is usually
part of the domain logic (store data in a database or read a file for example).

Although all the non-deterministic and effectful interactions are orchestrated
in the shell -- which is unequivocally positive -- the shell is likely to
contain substantial parts of the domain logic and grow quite complex and become
hard to maintain in large programs.  The natural evolution is to make even more
functions pure and focus more on the separation of concerns between domain logic
and infrastructure.  This can be achieved by representing effectful interactions
as pure values and separating the evaluation and effectful execution from their
pure representations.  See [Composable Effects](/composable_effects) for
details.

## When to reach for this pattern

It is always recommended to reach for this pattern as it always improves
separation of concerns, testability, and maintainability.

## When _not_ to reach for this pattern

In very rare cases, when performance is really critical and profiling your
application shows that the separation into different functions causes too much
overhead, optimizations like memoizations or other impure algorithms might be
valid reasons not to separate pure and impure parts but to inline them.  But
this is almost never the case.

## Example

Our simple example application reads user input, increments the input, and
outputs the result:

```ocaml
fun increment() : Unit = {
  print(read() + 1);
}
```

The `increment` function couples the I/O code for reading and for displaying the
result tightly to the pure logic for incrementing a value.  We can refactor this
code to

- a pure function that lives in our functional core with the single
  responsibility to compute the result:

```ocaml
fun increment(Integer n) : Integer = {
  return n + 1;
}
```

- a side-effecting function with the single responsibility to supply the input
  to the pure function:

```ocaml
fun input() : Integer = {
  return read();
}
```

- a side-effecting function with the single responsibility to do something with
  the result of the pure function:

```ocaml
fun output(Integer n) : Unit = {
  print(n);
}
```

Our application's entry point function orchestrates the side-effecting functions
of our imperative shell and calls the pure functions of the functional core:

```ocaml
fun main () : Unit = {
  n = input();
  n' = increment(n);
  output(n');
}
```

Handling of errors and non-determinism is left out here, but can all happen
locally and coordinated in the `main` function.  See [Composable Error
Handling](/composable_error_handling) for details.

What we see here with this small example applies to larger, more complex
programs.
