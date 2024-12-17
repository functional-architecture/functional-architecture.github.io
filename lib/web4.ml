module StringMap = Map.Make(String)

(* open Effect *)
(* open Effect.Deep *)

type url = string list

let string_of_url u = String.concat "/" u

type ref = {
  id : string;
}

let ref_of_string s = {
  id = s;
}

(* type _ Effect.t += Deref: ref -> string t *)
(* let deref r = perform (Deref r) *)

(* let handle_refs f = *)
(*   try_with f () *)
(*     { *)
(*       effc = fun (type a) (eff: a t) -> *)
(*         match eff with *)
(*         | Deref r -> Some (fun (k : (a, _) continuation) -> continue k r.id) *)
(*         | _ -> None *)
(*     } *)

(* let some_ref = { *)
(*   id = "moin"; *)
(* } *)

(* let bla () = "foo" ^ (deref some_ref) *)

(* let foo = handle_refs bla *)


type 'a web =
  | Const : string -> 'a web
  | Map : (string -> string) * 'a web -> 'a web
  | Lift2 : (string -> string -> string) * 'a web * 'a web -> 'a web
  | Link : ref -> 'a web
  | Match : ('c -> ('a * 'b) option) * ('a * 'b web) list * 'c web -> 'c web
  | Refer : ref * 'a web -> 'a web
  | With_token : (ref -> 'a web) -> 'a web
  | Not_found : 'a web
  | Resource : string -> 'a web
  | Img : ref -> 'a web

let div x y = Lift2 ((^), x, y)

let metch ?(default = Not_found) split cases =
  Match (split, cases, default)

let split_path path =
  match path with
  | [] -> None
  | (p :: ps) -> Some (p, ps)

let match_seg ?(default = Not_found) (cases : (string * 'a web) list) =
  metch ~default:default split_path cases

(*
   1. Compile to maps
   2. implement refer, link, and with_token
   3. implement all sorts of html items
*)

type ref_generator = int
let gen_ref rg = (ref_of_string (string_of_int rg), rg + 1)
let initial_ref_gen = 0

let rec resolve_refs_acc : type a . a web -> ref_generator -> url -> (ref -> url option) -> (ref -> url option) =
  fun w ref_gen url_here url_of_ref r ->
    match (url_of_ref r) with
    | Some url -> Some url
    | None ->
      match w with
      | Const _ -> None
      | Map (_, w') -> resolve_refs_acc w' ref_gen url_here url_of_ref r
      | Lift2 (_, x, y) -> (match resolve_refs_acc x ref_gen url_here url_of_ref r with
          | Some url -> Some url
          | None -> resolve_refs_acc y ref_gen url_here url_of_ref r)
      | Resource _ -> None
      | Img _ -> None
      | Link _ -> None
      | Not_found -> None
      | Refer (r', w') -> if r' = r
                             then Some url_here
                             else resolve_refs_acc w' ref_gen url_here url_of_ref r
      | With_token k -> let (new_ref, ref_gen') = gen_ref ref_gen in
        resolve_refs_acc (k new_ref) ref_gen' url_here url_of_ref r
      | Match (split, cases, default) ->
        match cases with
        | [] -> resolve_refs_acc default ref_gen url_here url_of_ref r
        | ((_comparand, w') :: cases') ->
          match resolve_refs_acc w' ref_gen (List.append url_here ["TODO"]) url_of_ref r with
          | Some url -> Some url
          | None -> resolve_refs_acc (Match (split, cases', default)) ref_gen url_here url_of_ref r

let resolve_refs : type a . a web -> (ref -> url option) =
  fun w -> resolve_refs_acc w initial_ref_gen [] (fun _ -> None)

let resolve_refs' : type a . a web -> (ref -> url) =
  fun w r -> Option.get (resolve_refs w r)


let rec run_fun : type a . (ref -> url) -> a web -> ref_generator -> a -> string =
  fun url_of_ref w ref_gen a ->
    match w with
    | Const s -> s
    | Map (f, w') -> f (run_fun url_of_ref w' ref_gen a)
    | Lift2 (f, x, y) -> f (run_fun url_of_ref x ref_gen a) (run_fun url_of_ref y ref_gen a)
    | Resource data -> "Some resource: " ^ data
    | Img r -> "<img src=" ^ (string_of_url (url_of_ref r)) ^ " />"
    | Link r -> "Link to: " ^ (string_of_url (url_of_ref r))
    | Not_found -> "not found"
    | Refer (_, w') -> run_fun url_of_ref w' ref_gen a
    | With_token k -> let (new_ref, ref_gen') = gen_ref ref_gen in
      run_fun url_of_ref (k new_ref) ref_gen' a
    | Match (split, cases, default) ->
      match (split a) with
      | None -> run_fun url_of_ref default ref_gen a
      | Some (x, y) -> match cases with
        | [] -> run_fun url_of_ref default ref_gen a
        | ((comparand, web') :: cases_) ->
          if comparand = x
          then run_fun url_of_ref web' ref_gen y
          else run_fun url_of_ref (Match (split, cases_, default)) ref_gen a

let run_f w = run_fun (resolve_refs' w) w initial_ref_gen

(* Examples *)

let ex1 =
  match_seg
    [("juergen", Const "Ja moin ich bin juerg");
     ("frank", Const "undich frank, mein fote ist: ")]

let ex2 = div ex1 ex1

let ex3 =
  match_seg
    [("employees", ex1);
     ("about", Const "A very nice website")]

let f1 (x, y) : (int * int) option = Some (x, y)

let f2 x = Some (x, ())

let ex4 =
  metch
    f1
    [(1, metch f2 [(4, Const "1 --> 4")]);
     (2, Const "2,3");
     (3, Const "3,4")]

let ex5 =
  With_token
    (fun r ->
       match_seg
         [("employees", Refer (r, ex3));
          ("about",
           div
             (Const "hier geht zu employes: ")
             (Link r))])

let ex1c = run_f ex1


(* let juergen = "Juergen" *)
(* let frank = "Frank" *)

(* let website_for_finance_department goto_sergey = *)
(*   with_token *)
(*     (fun tfrank -> *)
(*        (match_segment *)
(*           [(juergen, *)
(*             div *)
(*               (img (load "juergen.jpg")) *)
(*               (with_token *)
(*                  (fun t -> *)
(*                     (match_or *)
(*                        [("bild_von_juergen.jpg", (load ~ref:t "juergen.jpg"))] *)
(*                        (img t)))) *)
(*               (text "Juergen ist der coolste hier. Er arbeitet mit Frank: ") *)
(*               (link tfrank)); *)
(*            (frank, *)
(*             refer *)
(*               tfrank *)
(*               (div *)
(*                  (text "ja frank halt, er arbeitet viel mit sergey aus dem Resarch-Department") *)
(*                  (link goto_sergey)))])) *)

(* let go_sergey = ["research"; "sergey"] *)

(* let website_for_company = *)
(*   with_token *)
(*     (fun tserg -> *)
(*        (match_segment *)
(*           [("finance", website_for_finance_department tserg); *)
(*            ("research", (match_segment *)
(*                            [("sergey", refer tserg (text "ja moinle, hier die webstei von serg"))]))])) *)
