type 'a web

val empty : 'a web

val pure : 'a -> 'a web

val map : ('a -> 'b) -> 'a web -> 'b web

val map2 : ('a -> 'b -> 'c) -> 'a web -> 'b web -> 'c web

val mapn : ('a list -> 'b) -> 'a web list -> 'b web

val sequence : 'a web list -> 'a list web

val seg : string -> 'a web -> 'a web

val (||) : 'a web -> 'a web -> 'a web

val case : (string * 'a web) list -> 'a web -> 'a web

val case_else_fail : (string * 'a web) list -> 'a web

val resource : string -> 'a web

type ref

val with_ref : (ref -> 'a web) -> 'a web

val refer : ref -> 'a web -> 'a web

val deref : ref -> string

val (let&) : string -> (ref -> 'a web) -> 'a web
val (let@) : (string * string) -> (ref -> 'a web) -> 'a web

val render : string web -> unit

type url

type 'a or_resource

val run_fun : 'a web -> (url -> 'a or_resource)


