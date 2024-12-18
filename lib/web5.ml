module M = Map.Make(String)

open Effect
open Effect.Deep
open Tyxml.Html

type ref = {
  id : int;
}

let mk_ref i = {
  id = i;
}

type ref_generator = int
let gen_ref rg = (mk_ref rg, rg + 1)
let initial_ref_gen = 0

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

let string_of_url u = String.concat "/" u.path


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
  | Not_found : 'a web
  | Const : 'a -> 'a web
  | Map : ('a -> 'b) * 'a web -> 'b web
  | Lift2 : ('a -> 'b -> 'c) * 'a web * 'b web -> 'c web
  | With_ref : (ref -> 'a web) -> 'a web
  | Refer : ref * 'a web -> 'a web
  | Resource : string -> 'a web
  | Match : (string * 'a web) list * 'a web -> 'a web

let map f x = Map (f, x)

let map2 f x y = Lift2 (f, x, y)

let case cases default = Match (cases, default)

let case_else_fail cases = case cases Not_found

let div x y = Lift2 ((^), x, y)

let with_ref k = With_ref k

let refer r w = Refer (r, w)

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

let rec resolve_acc : type a . a web -> ref_generator -> url -> (ref -> url option) -> (ref -> url option) =
  fun w ref_gen url_here url_of_ref r ->
    match (url_of_ref r) with
    | Some url -> Some url
    | None ->
      match w with
      | Not_found -> None
      | Const _ -> None
      | Map (_, w') -> resolve_acc w' ref_gen url_here url_of_ref r
      | Lift2 (_, x, y) -> (match resolve_acc x ref_gen url_here url_of_ref r with
          | Some url -> Some url
          | None -> resolve_acc y ref_gen url_here url_of_ref r)
      | With_ref k -> let (new_ref, ref_gen') = gen_ref ref_gen in
        resolve_acc (k new_ref) ref_gen' url_here url_of_ref r
      | Refer (r', w') -> if r = r'
                             then Some url_here
                             else resolve_acc w' ref_gen url_here url_of_ref r
      | Resource _ -> None
      | Match (cases, default) ->
        match cases with
        | [] -> resolve_acc default ref_gen url_here url_of_ref r
        | ((segment, w') :: cases') ->
          match resolve_acc w' ref_gen (url_snoc url_here segment) url_of_ref r with
          | Some url -> Some url
          | None -> resolve_acc (Match (cases', default)) ref_gen url_here url_of_ref r

let resolve w r = Option.get (resolve_acc w initial_ref_gen empty_url (fun _ -> None) r)

let option_lift_2 f xo yo =
  Option.bind xo
    (fun x ->
       Option.map (f x) yo)

let either_lift_2_left f x y =
  match x with
  | Either.Right x' -> Either.Right x'
  | Either.Left x' -> match y with
    | Either.Right y' -> Either.Right y'
    | Either.Left y' -> Either.Left (f x' y')

let rec run_fun_acc : type a . a web -> (ref -> url) -> ref_generator -> (url -> a or_resource) =
  fun w url_of_ref ref_gen u ->
    match w with
    | Not_found -> Fail
    | Const x -> Value x
    | Map (f, w') -> or_resource_map f (run_fun_acc w' url_of_ref ref_gen u)
    | Lift2 (f, x, y) -> or_resource_map_2 f (run_fun_acc x url_of_ref ref_gen u) (run_fun_acc y url_of_ref ref_gen u)
    | With_ref k -> let (new_ref, ref_gen') = gen_ref ref_gen in
      run_fun_acc (k new_ref) url_of_ref ref_gen' u
    | Refer (_, w') -> run_fun_acc w' url_of_ref ref_gen u
    | Resource s -> Resource s
    | Match (cases, default) ->
      match cases with
      | [] -> run_fun_acc default url_of_ref ref_gen u
      | ((segment, w') :: cases') ->
        match u.path with
        | [] -> run_fun_acc default url_of_ref ref_gen u
        | segment' :: u' ->
          if segment = segment'
             then run_fun_acc w' url_of_ref ref_gen (mk_url u')
             else run_fun_acc (Match (cases', default)) url_of_ref ref_gen u

let run_fun : 'a web -> (url -> 'a or_resource) =
  fun w u -> run_fun_acc w (resolve w) initial_ref_gen u


(* ----- *)


type 'a defaultMap = {
  map : 'a M.t;
  dflt : 'a;
}

let default_map_just v = {
  map = M.empty;
  dflt = v;
}

let default_map_map f dmap = {
  map = M.map f dmap.map;
  dflt = f dmap.dflt;
}

let default_map_map_2 f m1 m2 = {
  map =
    M.merge
      (fun _k v1 v2 ->
         match (v1, v2) with
         | None, None -> None
         | Some s1, None -> Some (f s1 m2.dflt)
         | None, Some s2 -> Some (f m1.dflt s2) 
         | Some s1, Some s2 -> Some (f s1 s2))
      m1.map
      m2.map;
  dflt = f m1.dflt m2.dflt;
}

let prepend_segment seg m = {
  map =
    M.fold
      (fun k v acc ->
         M.add
           (seg ^ "/" ^ k)
           v
           acc)
      m.map
      (M.singleton seg m.dflt);
  dflt = Fail;
}

let rec run_dmap_acc : type a . a web -> (ref -> url) -> ref_generator -> a or_resource defaultMap =
  fun w url_of_ref ref_gen ->
    match w with
    | Not_found -> { map = M.empty; dflt = Fail; }
    | Const s -> default_map_just (Value s)
    | Map (f, w') ->
      default_map_map
        (or_resource_map f)
        (run_dmap_acc w' url_of_ref ref_gen)
    | Lift2 (f, x, y) ->
      default_map_map_2
        (or_resource_map_2 f)
        (run_dmap_acc x url_of_ref ref_gen)
        (run_dmap_acc y url_of_ref ref_gen)
    | With_ref k -> let (new_ref, ref_gen') = gen_ref ref_gen in
      run_dmap_acc (k new_ref) url_of_ref ref_gen'
    | Refer (_, w') -> run_dmap_acc w' url_of_ref ref_gen
    | Resource s -> default_map_just (Resource s)
    | Match (cases, default) ->
      match cases with
      | [] -> run_dmap_acc default url_of_ref ref_gen
      | ((segment, w') :: cases') ->
        let inner = run_dmap_acc w' url_of_ref ref_gen in
        let this = prepend_segment segment inner in
        let other = run_dmap_acc (Match (cases', default)) url_of_ref ref_gen in
        {
          map = M.union
                  (fun _k v1 _v2 -> Some v1)
                  this.map
                  other.map;
          dflt = other.dflt;
        }

let run_dmap : 'a web -> 'a or_resource defaultMap =
  fun w ->
  (handle_refs
     (* for calls from resolve: return some dummy urls *)
     (fun _ -> empty_url)
     (fun _ ->
        let url_of_ref = resolve w in
        handle_refs url_of_ref (fun _ -> run_dmap_acc w url_of_ref initial_ref_gen)))

let maybe_string_of x =
  Option.map
    (fun x ->
       match x with
       | Either.Left s -> s
       | Either.Right s -> s)
    x

let map_of_dmap : string or_resource defaultMap -> string M.t =
  fun dm ->
  M.fold
    (fun k v acc ->
       match v with
       | Fail -> acc
       | Resource s -> M.add k s acc
       | Value s -> M.add (k ^ "/index.html") s acc)
    dm.map
    (match dm.dflt with
     | Fail -> M.empty
     | Value s -> (M.singleton "./index.html" s)
     | Resource s -> (M.singleton "undefined.undefined" s))

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

let render : string M.t -> unit =
  M.iter
    (fun filename content ->
      Printf.printf "Rendering %s\n" filename;
      write filename content)

(* Examples *)

let img_text filename content =
  with_ref
    (fun r ->
       case
         [(filename, refer r (Resource content))]
         (Const ("<img src=" ^ (deref r) ^ " />")))

let ex0 =
  div
    (Const "undich frank, mein fote ist: ")
    (img_text "frank.jpg" "BINARY")

let ex1 =
  case_else_fail
    [("juergen", Const "Ja moin ich bin juerg");
     ("frank", ex0)]

let ex2 = div ex1 ex1

let ex3 =
  case_else_fail
    [("employees", ex1);
     ("about", Const "A very nice website")]

let ex5 =
  with_ref
    (fun r ->
       case_else_fail
         [("employees", Refer (r, ex3));
          ("about",
           div
             (Const "hier geht zu employes: ")
             (Const (deref r)))])

let ex6 : [`Div] elt web =
  map2
    (fun x y -> Tyxml.Html.div [x; y])
    (Const (p [txt "sup"]))
    (Const (p [txt "dawg"]))

let ex7 =
  map
    (fun x ->
       html
         (head (title (txt "Hi")) [])
         (body [x]))
    ex6

let pr_html x = Format.asprintf "%a" (Tyxml.Html.pp ~indent:false ()) x

let ex8 = map pr_html ex7

let dm8 = run_dmap ex8
