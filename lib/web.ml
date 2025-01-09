module M = Map.Make(String)

open Effect
open Effect.Deep

type ref = {
  id : int;
}

let inc_ref r = {
  id = r.id + 1;
}

let string_of_ref r =
  string_of_int r.id

let refs_eq r1 r2 = r1.id = r2.id

let initial_ref = {
  id = 0;
}

type url = {
  path : string list;
}

let mk_url s = {
  path = s;
}

let empty_url = {
  path = [];
}

let url_snoc u seg = {
  path = List.append u.path [seg]
}

let string_of_url u = "/" ^ String.concat "/" u.path

type _ Effect.t += Deref: ref -> string t
let deref r = perform (Deref r)

let handle_refs (url_of_ref : ref -> url) f =
  try_with f ()
    {
      effc = fun (type a) (eff: a t) ->
        match eff with
        | Deref r -> Some (fun (k : (a, _) continuation) -> continue k (string_of_url (url_of_ref r)))
        | _ -> None
    }

(* url -> string, for now *)
type 'a web =
  (* aka empty (Alternative) *)
  | Not_found : 'a web
  (* aka pure *)
  | Const : 'a -> 'a web
  (* aka fmap, web is a functor *)
  | Map : ('a -> 'b) * 'a web -> 'b web
  (* aka liftA2, web is an applicative functor *)
  | Lift2 : ('a -> 'b -> 'c) * 'a web * 'b web -> 'c web

  | With_ref : (ref -> 'a web) -> 'a web
  | Refer : ref * 'a web -> 'a web

  | Resource : string -> 'a web

  (* primitive parser *)
  | Seg : string * 'a web -> 'a web
  (* aka <|> *)
  | Or : 'a web * 'a web -> 'a web

let empty = Not_found

let pure x = Const x

let map f x = Map (f, x)

let map2 f x y = Lift2 (f, x, y)

let rec sequence xs =
  match xs with
  | [] -> pure []
  | (x :: xs) -> map2 List.cons x (sequence xs)

let mapn f xs = map f (sequence xs)

let seg s w = Seg (s, w)

let (||) x y = Or (x, y)

let case cases default =
  List.fold_right
    (fun (seg, w) acc ->
       Or (Seg (seg, w), acc))
    cases
    default

let case_else_fail cases = case cases Not_found

let resource r = Resource r

let with_ref k = With_ref k

let refer r w = Refer (r, w)

let with_resource ?(filename = "") contents k =
  let filename = match filename with
    | "" -> string_of_int (Hashtbl.hash contents)
    | _ -> filename in
  with_ref
    (fun r ->
       case
         [(filename, refer r (Resource contents))]
         (k r))

let (let&) x f = with_resource x f
let (let@) (name, x) f = with_resource ~filename:name x f
let (let+) x f = map f x
let (let$) _x f = with_ref f
let (let^) (path, w) f = with_ref (fun r -> seg path (refer r w) || (f r))

(* --- *)

type 'a or_resource =
  | Value of 'a
  | Resource of string
  | Fail

let or_resource_map f x =
  match x with
  | Value v -> Value (f v)
  | Resource s -> Resource s
  | Fail -> Fail

let or_resource_map_2 f x y =
  match (x, y) with
  | (Value v, Value w) -> Value (f v w)
  | (Resource r, _) -> Resource r
  | (_, Resource r) -> Resource r
  | _ -> Fail

type 'a lowered =
  | LNot_found : 'a lowered
  | LConst : 'a -> 'a lowered
  | LMap : ('a -> 'b) * 'a lowered -> 'b lowered
  | LMap2 : ('a -> 'b -> 'c) * 'a lowered * 'b lowered -> 'c lowered
  | LRefer : ref * 'a lowered -> 'a lowered
  | LResource : string -> 'a lowered
  | LSeg : string * 'a lowered -> 'a lowered
  | LOr : 'a lowered * 'a lowered -> 'a lowered

let rec lower' : type a . ref -> a web -> (ref * a lowered) =
  fun ref w ->
  match w with
  | Not_found -> (ref, LNot_found)
  | Const x -> (ref, LConst x)
  | Map (f, w') -> let (ref', l) = lower' ref w' in (ref', LMap (f, l))
  | Lift2 (f, w1, w2) ->
    let (ref1, l1) = lower' ref w1 in
    let (ref2, l2) = lower' ref1 w2 in
    (ref2, LMap2 (f, l1, l2))
  | With_ref k -> lower' (inc_ref ref) (k ref)
  | Refer (r, w) -> let (ref', l) = lower' ref w in (ref' , LRefer (r, l))
  | Resource s -> (ref, LResource s)
  | Seg (s, w') -> let (ref', l) = lower' ref w' in (ref', LSeg (s, l))
  | Or (w1, w2) ->
    let (ref1, l1) = lower' ref w1 in
    let (ref2, l2) = lower' ref1 w2 in
    (ref2, LOr (l1, l2))

let lower w = let (_, l) = lower' initial_ref w in l

let opt_or o1 o2 =
  match o1 with
  | Some x -> Some x
  | None -> o2

let rec resolve' : type a . a lowered -> url -> (ref -> url option) =
  fun l url_here r ->
  match l with
  | LMap (_, l') -> resolve' l' url_here r
  | LMap2 (_, l1, l2) -> opt_or (resolve' l1 url_here r) (resolve' l2 url_here r)
  | LRefer (r', l') ->
    if (refs_eq r r')
    then (Some url_here)
    else resolve' l' url_here r
  | LSeg (seg, l') -> resolve' l' (url_snoc url_here seg) r
  | LOr (l1, l2) -> opt_or (resolve' l1 url_here r) (resolve' l2 url_here r)
  | _ -> None

let resolve w r =
  Option.get (resolve' (lower w) empty_url r)

let rec ind i =
  if i = 0
     then ""
     else "  " ^ ind (i - 1)

let rec string_of_lowered' : type a . int -> a lowered -> string
  = fun i l ->
    match l with
    | LNot_found -> ind i ^ "Not_found"
    | LConst _ -> ind i ^ "Const: TODO"
    | LMap (_, l') -> ind i ^ "Map:\n" ^ string_of_lowered' (i + 1) l'
    | LMap2 (_, l1, l2) -> ind i ^ "Map2:\n" ^ (string_of_lowered' (i + 1) l1) ^ "\n" ^ (string_of_lowered' (i + 1) l2)
    | LRefer (r, l') -> ind i ^ "Refer: " ^ string_of_ref r ^ "\n" ^ (string_of_lowered' (i + 1) l')
    | LResource _ -> ind i ^ "Resource"
    | LSeg (seg, l') ->
      ind i ^ "Seg: " ^ seg ^ "\n" ^ (string_of_lowered' (i + 1) l')
    | LOr (l1, l2) ->
      ind i ^ "Or:\n" ^ (string_of_lowered' (i + 1) l1) ^ "\n" ^ (string_of_lowered' (i + 1) l2)

let string_of_lowered l = string_of_lowered' 0 l

let string_of_web w =
  (handle_refs
     (* for calls from resolve: return some dummy urls *)
     (fun _ -> empty_url)
     (fun _ ->
        let url_of_ref = resolve w in
        handle_refs url_of_ref (fun _ -> string_of_lowered (lower w))))

let rec run_fun' : type a . a lowered -> (ref -> url) -> (url -> a or_resource) =
  fun l url_of_ref u ->
  match l with
  | LNot_found -> Fail
  | LConst x -> Value x
  | LMap (f, l') -> or_resource_map f (run_fun' l' url_of_ref u)
  | LMap2 (f, l1, l2) -> or_resource_map_2
                           f
                           (run_fun' l1 url_of_ref u)
                           (run_fun' l2 url_of_ref u)
  | LRefer (_, l') -> run_fun' l' url_of_ref u
  | LResource s -> Resource s
  | LSeg (seg, l') ->
    (match u.path with
     | [] -> Fail
     | segment' :: u' ->
       if seg = segment'
       then run_fun' l' url_of_ref (mk_url u')
       else Fail)
  | LOr (l1, l2) ->
      (match run_fun' l1 url_of_ref u with
       | Value v -> Value v
       | Resource r -> Resource r
       | Fail -> run_fun' l2 url_of_ref u)

let run_fun : 'a web -> (url -> 'a or_resource) =
  fun w u -> run_fun' (lower w) (resolve w) u


(* ----- *)

module SDmap = Dmap.Make(String)

let rec run_dmap' : type a . a lowered -> (ref -> url) -> a or_resource SDmap.t =
  fun l url_of_ref ->
  match l with
  | LNot_found -> SDmap.pure Fail
  | LConst x -> SDmap.pure (Value x)
  | LMap (f, l') -> SDmap.map
                      (or_resource_map f)
                      (run_dmap' l' url_of_ref)
  | LMap2 (f, l1, l2) -> SDmap.map2
                           (or_resource_map_2 f)
                           (run_dmap' l1 url_of_ref)
                           (run_dmap' l2 url_of_ref)
  | LRefer (_, l') -> run_dmap' l' url_of_ref
  | LResource s -> SDmap.pure (Resource s)
  | LSeg (seg, l') ->
    SDmap.shift
      (fun sego -> match sego with
         | None -> seg
         | Some s -> seg ^ "/" ^ s)
      Fail
      (run_dmap' l' url_of_ref)
  | LOr (l1, l2) ->
      let dm1 = run_dmap' l1 url_of_ref in
      let dm2 = run_dmap' l2 url_of_ref in
      SDmap.union (fun v1 _v2 -> Some v1) dm1 dm2

let run_dmap : 'a web -> 'a or_resource SDmap.t =
  fun w ->
  (handle_refs
     (* for calls from resolve: return some dummy urls *)
     (fun _ -> empty_url)
     (fun _ ->
        let url_of_ref = resolve w in
        handle_refs url_of_ref (fun _ -> run_dmap' (lower w) url_of_ref)))

let map_of_dmap : string or_resource SDmap.t -> string M.t =
  fun dm ->
  SDmap.fold
    (fun k v acc ->
       match v with
       | Fail -> acc
       | Resource s -> M.add k s acc
       | Value s -> M.add (k ^ "/index.html") s acc)
    dm
    (fun dflt ->
       (match dflt with
        | Fail -> M.empty
        | Value s -> (M.singleton "./index.html" s)
        | Resource s -> (M.singleton "undefined.undefined" s)))

let rec create_dir dir =
  print_endline @@ "create_dir: " ^ dir;
  if Sys.file_exists dir
  then ()
  else let prefix = Filename.dirname dir in
    create_dir prefix;
    Sys.mkdir dir 0o755

let write file s =
  let dir = Filename.dirname file in
  print_endline @@ "writing to: " ^ file;
  create_dir dir;
  Out_channel.with_open_bin file (fun ch -> Out_channel.output_string ch s)

let render_map dir string_map =
  M.iter
    (fun filename content ->
      Printf.printf "Rendering %s\n" filename;
      write (dir ^ "/" ^ filename) content)
  string_map

let render ?(directory = ".") w =
  render_map directory (map_of_dmap (run_dmap w))
