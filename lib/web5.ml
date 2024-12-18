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

type 'a or_resource = ('a, string) Either.t

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

let rec run_fun_acc : type a . a web -> (ref -> url) -> ref_generator -> (url -> a or_resource option) =
  fun w url_of_ref ref_gen u ->
    match w with
    | Not_found -> None
    | Const x -> Some (Either.Left x)
    | Map (f, w') -> Option.map (Either.map_left f) (run_fun_acc w' url_of_ref ref_gen u)
    | Lift2 (f, x, y) -> option_lift_2 (either_lift_2_left f) (run_fun_acc x url_of_ref ref_gen u) (run_fun_acc y url_of_ref ref_gen u)
    | With_ref k -> let (new_ref, ref_gen') = gen_ref ref_gen in
      run_fun_acc (k new_ref) url_of_ref ref_gen' u
    | Refer (_, w') -> run_fun_acc w' url_of_ref ref_gen u
    | Resource data -> Some (Either.Right data)
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

let run_fun : 'a web -> (url -> 'a or_resource option) =
  fun w u -> run_fun_acc w (resolve w) initial_ref_gen u


(* ----- *)


type 'a defaultMap = {
  map : ('a option) M.t;
  dflt : ('a option);
}

let default_map_just v = {
  map = M.empty;
  dflt = Some v;
}

let default_map_nothing = {
  map = M.empty;
  dflt = None;
}

let default_map_map f dmap = {
  map = M.map (Option.map f) dmap.map;
  dflt = Option.map f dmap.dflt;
}

let default_map_lift2 f m1 m2 = {
  map =
    M.merge
      (fun _k v1 v2 ->
         match (v1, v2) with
         | None, None -> None
         | Some s1, None -> Some (option_lift_2 f s1 m2.dflt)
         | None, Some s2 -> Some (option_lift_2 f m1.dflt s2) 
         | Some s1, Some s2 -> Some (option_lift_2 f s1 s2))
      m1.map
      m2.map;
  dflt = option_lift_2 f m1.dflt m2.dflt;
}

let prepend_segment seg m = {
  map =
    M.fold
      (fun k v acc ->
         M.add
           (seg ^ k)
           v
           acc)
      m.map
      (M.singleton seg m.dflt);
  dflt = None;
}

let rec run_map_acc : type a . a web -> (ref -> url) -> ref_generator -> a or_resource defaultMap =
  fun w url_of_ref ref_gen ->
    match w with
    | Not_found -> { map = M.empty; dflt = None; }
    | Const s -> default_map_just (Either.Left s)
    | Map (f, w') -> default_map_map (Either.map_left f) (run_map_acc w' url_of_ref ref_gen)
    | Lift2 (f, x, y) -> default_map_lift2 (either_lift_2_left f) (run_map_acc x url_of_ref ref_gen) (run_map_acc y url_of_ref ref_gen)
    | With_ref k -> let (new_ref, ref_gen') = gen_ref ref_gen in
      run_map_acc (k new_ref) url_of_ref ref_gen'
    | Refer (_, w') -> run_map_acc w' url_of_ref ref_gen
    | Resource _data -> default_map_nothing (* TODO *)
    | Match (cases, default) ->
      match cases with
      | [] -> run_map_acc default url_of_ref ref_gen
      | ((segment, w') :: cases') ->
        let inner = run_map_acc w' url_of_ref ref_gen in
        let this = prepend_segment segment inner in
        let other = run_map_acc (Match (cases', default)) url_of_ref ref_gen in
        {
          map = M.union
                  (fun _k v1 _v2 -> Some v1)
                  this.map
                  other.map;
          dflt = other.dflt;
        }

let run_map : 'a web -> 'a or_resource defaultMap =
  fun w ->
  (handle_refs
     (* for calls from resolve: return some dummy urls *)
     (fun _ -> empty_url)
     (fun _ ->
        let url_of_ref = resolve w in
        handle_refs url_of_ref (fun _ -> run_map_acc w url_of_ref initial_ref_gen)))

(* Examples *)

let ex1 =
  case_else_fail
    [("juergen", Const "Ja moin ich bin juerg");
     ("frank", Const "undich frank, mein fote ist: ")]

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

let ex6 =
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
