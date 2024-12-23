module M = Map.Make(String)

open Effect
open Effect.Deep

type ref = {
  id : int;
}

let mk_ref i = {
  id = i;
}

let refs_eq r1 r2 = r1.id = r2.id

type ref_generator = int
let gen_ref rg = (mk_ref rg, rg + 1)
let initial_ref_gen = 0
let ref_gen_split rg = rg + 1000

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

let rec lower : type a . ref_generator -> a web -> a lowered =
  fun ref_gen w ->
  match w with
  | Not_found -> LNot_found
  | Const x -> LConst x
  | Map (f, w') -> LMap (f, lower ref_gen w')
  | Lift2 (f, w1, w2) -> LMap2 (f, lower ref_gen w1, lower (ref_gen_split ref_gen) w2)
  | With_ref k ->
    let (new_ref, ref_gen') = gen_ref ref_gen in
    lower ref_gen' (k new_ref)
  | Refer (r, w) -> LRefer (r, lower ref_gen w)
  | Resource s -> LResource s
  | Seg (s, w') -> LSeg (s, lower ref_gen w')
  | Or (w1, w2) -> LOr (lower ref_gen w1, lower (ref_gen_split ref_gen) w2)

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
  Option.get (resolve' (lower initial_ref_gen w) empty_url r)

let rec run_fun_acc : type a . a web -> (ref -> url) -> ref_generator -> (url -> a or_resource) =
  fun w url_of_ref ref_gen u ->
    match w with
    | Or (x, y) ->
      (match run_fun_acc x url_of_ref ref_gen u with
       | Value v -> Value v
       | Resource r -> Resource r
       | Fail -> run_fun_acc y url_of_ref (ref_gen_split ref_gen) u)
    | Seg (segment, w') ->
      (match u.path with
       | [] -> Fail
       | segment' :: u' ->
         if segment = segment'
         then run_fun_acc w' url_of_ref ref_gen (mk_url u')
         else Fail)
    | Not_found -> Fail
    | Const x -> Value x
    | Map (f, w') -> or_resource_map f (run_fun_acc w' url_of_ref ref_gen u)
    | Lift2 (f, x, y) -> or_resource_map_2
                           f
                           (run_fun_acc x url_of_ref ref_gen u)
                           (run_fun_acc y url_of_ref (ref_gen_split ref_gen) u)
    | With_ref k -> let (new_ref, ref_gen') = gen_ref ref_gen in
      run_fun_acc (k new_ref) url_of_ref ref_gen' u
    | Refer (_, w') -> run_fun_acc w' url_of_ref ref_gen u
    | Resource s -> Resource s

let run_fun : 'a web -> (url -> 'a or_resource) =
  fun w u -> run_fun_acc w (resolve w) initial_ref_gen u


(* ----- *)


type 'a defaultMap = {
  map : 'a M.t;
  dflt : 'a;
}

let default_map_const v = {
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
    | Or (x, y) ->
      let xdm = run_dmap_acc x url_of_ref ref_gen in
      let ydm = run_dmap_acc y url_of_ref (ref_gen_split ref_gen) in
      {
        map = M.union
                (fun _k v1 _v2 -> Some v1)
                xdm.map
                ydm.map;
        dflt = ydm.dflt;
      }
    | Seg (segment, w') ->
      prepend_segment segment (run_dmap_acc w' url_of_ref ref_gen)
    | Not_found -> { map = M.empty; dflt = Fail; }
    | Const s -> default_map_const (Value s)
    | Map (f, w') ->
      default_map_map
        (or_resource_map f)
        (run_dmap_acc w' url_of_ref ref_gen)
    | Lift2 (f, x, y) ->
      default_map_map_2
        (or_resource_map_2 f)
        (run_dmap_acc x url_of_ref ref_gen)
        (run_dmap_acc y url_of_ref (ref_gen_split ref_gen))
    | With_ref k -> let (new_ref, ref_gen') = gen_ref ref_gen in
      run_dmap_acc (k new_ref) url_of_ref ref_gen'
    | Refer (_, w') -> run_dmap_acc w' url_of_ref ref_gen
    | Resource s -> default_map_const (Resource s)

let run_dmap : 'a web -> 'a or_resource defaultMap =
  fun w ->
  (handle_refs
     (* for calls from resolve: return some dummy urls *)
     (fun _ -> empty_url)
     (fun _ ->
        let url_of_ref = resolve w in
        handle_refs url_of_ref (fun _ -> run_dmap_acc w url_of_ref initial_ref_gen)))

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

let render_map dir string_map =
  M.iter
    (fun filename content ->
      Printf.printf "Rendering %s\n" filename;
      write (dir ^ "/" ^ filename) content)
  string_map

let render ?(directory = ".") w =
  render_map directory (map_of_dmap (run_dmap w))

(* Examples *)

(* module H = Tyxml.Html *)

(* let div x y = Lift2 ((^), x, y) *)

(* let img_text filename content = *)
(*   with_ref *)
(*     (fun r -> *)
(*        case *)
(*          [(filename, refer r (Resource content))] *)
(*          (Const ("<img src=" ^ (deref r) ^ " />"))) *)

(* let ex0 = *)
(*   mapn *)
(*     (String.concat "...") *)
(*     [(Const "undich frank, mein fote ist: "); *)
(*      (img_text "frank.jpg" "BINARY")] *)

(* let ex1 = *)
(*   case_else_fail *)
(*     [("juergen", Const "Ja moin ich bin juerg"); *)
(*      ("frank", ex0)] *)

(* let ex2 = div ex1 ex1 *)

(* let ex3 = *)
(*   case_else_fail *)
(*     [("employees", ex1); *)
(*      ("about", Const "A very nice website")] *)

(* let ex5 = *)
(*   with_ref *)
(*     (fun r -> *)
(*        case_else_fail *)
(*          [("employees", Refer (r, ex3)); *)
(*           ("about", *)
(*            div *)
(*              (Const "hier geht zu employes: ") *)
(*              (Const (deref r)))]) *)

(* let ex6 : [`Div] H.elt web = *)
(*   mapn *)
(*     (Tyxml.Html.div ~a:[H.a_style "background: red"]) *)
(*     [(Const (H.p [H.txt "sup"])); *)
(*      (Const (H.p [H.txt "dawg"]))] *)

(* let read_file file = *)
(*   In_channel.with_open_bin file In_channel.input_all *)


(* let js = *)
(*   let& hljs_ref = (read_file "./js/highlight.min.js") in *)
(*   let@ java_ref = ("java.js", (read_file "./js/languages/java.js")) in *)
(*   (pure *)
(*      (H.script ~a:[H.a_script_type `Module] *)
(*         (H.txt *)
(*            (Printf.sprintf *)
(*               "import hljs from '%s' *)
(*                          import java from '%s' *)
(*                          hljs.registerLanguage('java', java); *)
(*                          hljs.highlightAll();" *)
(*               (deref hljs_ref) *)
(*               (deref java_ref))))) *)

(* let ex7 = *)
(*   map2 *)
(*     (fun x js -> *)
(*        H.html *)
(*          (H.head *)
(*             (H.title (H.txt "Hi")) *)
(*             [js]) *)
(*          (H.body [x])) *)
(*     ex6 *)
(*     js *)

(* let pr_html x = Format.asprintf "%a" (Tyxml.Html.pp ~indent:false ()) x *)

(* let ex8 = map pr_html ex7 *)
