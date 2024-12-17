module StringMap = Map.Make(String)

type web =
  | Text : string -> web
  | Div : web * web -> web
  | Link_relative : string list * string -> web
  | Link_absolute : string list * string -> web
  | Match_seg : (string * web) list -> web

let ex2 = Match_seg [("foo", Link_relative (["bar"], "Zu bar"));
                     ("bar", Link_relative (["foo"], "Zu foo"))]

let ex3 =
  Div (Text "Der tolle header", ex2)



let string_of_path path = String.concat "/" path

let rec denotation_prefix (prefix : string list) wb =
  match wb with
  | Text t -> fun _path -> Some t
  | Div (x, y) -> fun path ->
    Option.bind (denotation_prefix prefix x path)
      (fun res1 ->
         Option.bind (denotation_prefix prefix y path)
           (fun res2 ->
             Some (res1 ^ res2)))
  | Link_relative (dest, t) -> fun _path -> Some ("LINK: " ^ t ^ "(" ^ (string_of_path dest) ^ ")")
  | Link_absolute (dest, t) -> fun _path -> Some ("LINK: " ^ t ^ "(" ^ (string_of_path (List.append prefix dest)) ^ ")")
  | Match_seg [] -> fun _path -> None
  | Match_seg ((seg, next_web) :: cases) ->
    fun path ->
      match path with
      | [] -> None
      | seg_ :: segs ->
        if seg = seg_
        then denotation_prefix (List.append prefix [seg]) next_web segs
        else denotation_prefix prefix (Match_seg cases) path

let denotation wb = denotation_prefix [] wb

(* ---- *)

let option_lift_2 f xo yo =
  Option.bind xo
    (fun x ->
       Option.map (f x) yo)

type defaultStringMap = {
  map : (string option) StringMap.t;
  dflt : (string option);
}

let default_string_map_just v = {
  map = StringMap.empty;
  dflt = Some v;
}

let default_string_map_nothing = {
  map = StringMap.empty;
  dflt = None;
}

let default_string_map_cat m1 m2 = {
  map =
    StringMap.merge
      (fun _k v1 v2 ->
         match (v1, v2) with
         | None, None -> None
         | Some s1, None -> Some (option_lift_2 (^) s1 m2.dflt)
         | None, Some s2 -> Some (option_lift_2 (^) m1.dflt s2) 
         | Some s1, Some s2 -> Some (option_lift_2 (^) s1 s2))
      m1.map
      m2.map;
  dflt = option_lift_2 (^) m1.dflt m2.dflt;
}

let prepend_prefix prefix m =
  let prefixs = string_of_path prefix in {
  map =
    StringMap.fold
      (fun k v acc ->
         StringMap.add
           (prefixs ^ k)
           v
           acc)
      m.map
      (StringMap.singleton prefixs m.dflt);
  dflt = None;
}

let rec default_map_of_web_prefix (prefix : string list) wb =
  match wb with
  | Text t -> default_string_map_just t
  | Div (x, y) -> default_string_map_cat
                    (default_map_of_web_prefix prefix x)
                    (default_map_of_web_prefix prefix y)
  | Link_relative (dest, t) -> default_string_map_just
                                 ("LINK: " ^ t ^ "(" ^ (string_of_path dest) ^ ")")
  | Link_absolute (dest, t) -> default_string_map_just
                                 ("LINK: " ^ t ^ "(" ^ (string_of_path (List.append prefix dest)) ^ ")")
  | Match_seg [] -> default_string_map_nothing
  | Match_seg ((seg, next_web) :: cases) ->
    let next_prefix = (List.append prefix [seg]) in
    let inner = prepend_prefix next_prefix @@ default_map_of_web_prefix next_prefix next_web in
    let other = default_map_of_web_prefix prefix (Match_seg cases) in
    {
      map = 
        StringMap.union
          (fun _k v1 _v2 -> Some v1)
          inner.map
          other.map;
      dflt = inner.dflt;
    }

let default_map_of_web wb = default_map_of_web_prefix [] wb




