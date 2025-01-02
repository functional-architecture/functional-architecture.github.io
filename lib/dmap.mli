type 'a t

val pure : 'a -> 'a t

val map : ('a -> 'b) -> 'a t -> 'b t

val map2 : ('a -> 'b -> 'c) -> 'a t -> 'b t -> 'c t

val shift : string -> 'a -> 'a t -> 'a t

val union : ('a -> 'a -> 'a option) -> 'a t -> 'a t -> 'a t

val fold : (string -> 'a -> 'acc -> 'acc) -> 'a t -> ('a -> 'acc) -> 'acc
