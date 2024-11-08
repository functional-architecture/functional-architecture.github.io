open Tyxml.Html

type resource = {
  dest_path : string;
  data : string;
}

let make_resource dest data = {
  dest_path = dest;
  data = data;
}

let resource_file_path resource = resource.dest_path

let resource_url_path resource = "/" ^ resource.dest_path

let resource_data resource = resource.data

type ref = {
  id : string
}

let make_ref s = {
  id = s;
}

let ref_id ref = ref.id

let ref_file_path ref = (ref_id ref) ^ "/index.html"

let ref_url_path ref = "/" ^ (ref_id ref) ^ ""

let h lvl =
  match lvl with
  | 1 -> Tyxml.Html.h1
  | 2 -> Tyxml.Html.h2
  | 3 -> Tyxml.Html.h3
  | 4 -> Tyxml.Html.h4
  | 5 -> Tyxml.Html.h5
  | _ -> Tyxml.Html.h6

type element =
  | Fragment of element list
  | Attributed of [ | Html_types.common ] attrib list_wrap * element
  | P of Html_types.p_attrib attrib list_wrap * element
  | Titled of string * element
  | Link of string * page
  | Link_ref of string * ref
  | Text of string
  | Image of Html_types.img_attrib attrib list_wrap * string * resource
  | Image_ref of Html_types.img_attrib attrib list_wrap * string * ref
  | Identify of ref * element

and page =
  | LiftElement of string * ref option * element
  | WithRef of (ref -> page)
  | LiftResource of ref * resource

and website =
  | Pages of page list
  | WithRef of (ref -> website)

let make_website pages = Pages pages

let element_link_reference element =
  string_of_int (Hashtbl.hash element)

let element_ref e =
  make_ref @@ string_of_int (Hashtbl.hash e)

let rec html_of_element_block_h h_level element =
  match element with
  | Fragment _ -> assert(false)
  | Attributed (attrs, (Fragment es)) -> Tyxml.Html.div ~a:attrs (List.map (html_of_element_block_h h_level) es)
  | Attributed (attrs, e) -> Tyxml.Html.div ~a:attrs [(html_of_element_block_h h_level e)]
  | P (attrs, (Fragment es)) -> Tyxml.Html.p ~a:attrs (List.map html_of_element_inline es)
  | P (attrs, e) -> Tyxml.Html.p ~a:attrs [(html_of_element_inline e)]
  | Titled (title, e) -> Tyxml.Html.div [
      (h h_level) [Tyxml.Html.txt title];
      (html_of_element_block_h (h_level + 1) e)
    ]
  | Link (s, page) -> Tyxml.Html.a ~a:[a_href (ref_url_path (page_ref page))] [txt s]
  | Link_ref (s, ref) -> Tyxml.Html.a ~a:[a_href (ref_url_path ref)] [txt s]
  | Text s -> txt s
  | Image (attrs, alt, resource) -> Tyxml.Html.img
                                      ~src:(resource_url_path resource)
                                      ~alt:alt
                                      ~a:attrs
                                      ()
  | Image_ref (attrs, alt, ref) -> Tyxml.Html.img
                                          ~src:(ref_url_path ref)
                                          ~alt:alt
                                          ~a:attrs
                                          ()
  | Identify (ref, (Fragment es)) -> Tyxml.Html.div ~a:[a_id (ref_id ref)] (List.map (html_of_element_block_h h_level) es)
  | Identify (ref, e) -> Tyxml.Html.div ~a:[a_id (ref_id ref)] [html_of_element_block_h h_level e]

and html_of_element_inline element =
  match element with
  | Fragment _ -> assert(false)
  | Attributed (attrs, (Fragment es)) -> Tyxml.Html.span ~a:attrs (List.map html_of_element_inline es)
  | Attributed (attrs, e) -> Tyxml.Html.span ~a:attrs [(html_of_element_inline e)]
  | P _ -> assert(false)
  | Titled _ -> assert(false)
  | Link (s, page) -> Tyxml.Html.a ~a:[a_href (ref_url_path (page_ref page))] [txt s]
  | Link_ref (s, ref) -> Tyxml.Html.a ~a:[a_href (ref_url_path ref)] [txt s]
  | Text s -> txt s
  | Image (attrs, alt, resource) -> Tyxml.Html.img
                                      ~src:(resource_url_path resource)
                                      ~alt:alt
                                      ~a:attrs
                                      ()
  | Image_ref (attrs, alt, ref) -> Tyxml.Html.img
                                     ~src:(ref_url_path ref)
                                     ~alt:alt
                                     ~a:attrs
                                     ()
  | Identify (ref, (Fragment es)) -> Tyxml.Html.span ~a:[a_id (ref_id ref)] (List.map html_of_element_inline es)
  | Identify (ref, e) -> Tyxml.Html.span ~a:[a_id (ref_id ref)] [html_of_element_inline e]

and page_ref page =
  match page with
  | WithRef _ -> assert(false)
  | LiftResource (ref, _) -> ref
  | LiftElement (_title, refo, e) ->
    (match refo with
    | Some r -> r
    | None -> element_ref e)

let html_of_element_block = html_of_element_block_h 1

let append ?(a = []) elements = Attributed (a, (Fragment elements))
let p ?(a = []) elements = P (a, (Fragment elements))
let text s = Text s
let image ?(a = []) alt resource = Image (a, alt, resource)
let image_ref ?(a = []) alt ref = Image_ref (a, alt, ref)
let titled title elements = Titled (title, (Fragment elements))
let link (s : string) page = Link (s, page)
let link_ref (s : string) ref = Link_ref (s, ref)
let identify ref element = Identify (ref, element)

let page_of_element ?(ref) title content = LiftElement (title, ref, content)

let page_of_resource ref res = LiftResource (ref, res)

let with_ref k : website = WithRef k

let identify_page ref page =
  match page with
  | LiftElement (title, _, e) -> LiftElement (title, Some ref, e)
  | WithRef _ -> assert(false)
  | LiftResource (_, x) -> LiftResource (ref, x)


(* --- Rendering ---*)
module StringMap = Map.Make(String)

(** a.k.a. render *)
let rec resource_of_page page =
  let string_of_html html =
    Format.asprintf "%a" (Tyxml.Html.pp ~indent:false ()) html in
  match page with
  | LiftElement (title, _, e) -> make_resource
                                   title
                                   (string_of_html
                                       (html
                                          (head
                                             (Tyxml.Html.title (txt title))
                                             [(meta ~a:[a_http_equiv "content-type"; a_content "text/html; charset=utf-8"] ())])
                                          (body
                                             [html_of_element_block e])))
  | WithRef k -> resource_of_page (k (make_ref "TODO"))
  | LiftResource (_ref, resource) -> resource

let rec gather_website_resources website : resource StringMap.t =
  match website with
  | Pages pages -> List.fold_right
                     (fun page acc ->
                        StringMap.union
                          (fun _ _ x -> Some x)
                          acc
                          (gather_page_resources page))
                     pages
                     StringMap.empty
  | WithRef k -> gather_website_resources (k (make_ref "TODO"))

and gather_page_resources page : resource StringMap.t =
  let r = (resource_of_page page) in
  StringMap.add
    (resource_file_path r)
    r
    (match page with
     | LiftElement (_, _, e) -> gather_element_resources e
     | WithRef k -> gather_page_resources (k (make_ref "TODO"))
     | LiftResource (ref, resource) -> StringMap.singleton (ref_file_path ref) resource)

and gather_element_resources e : resource StringMap.t =
  match e with
  | Fragment es -> List.fold_right
                     (fun e acc ->
                        StringMap.union
                          (fun _ _ x -> Some x)
                          acc
                          (gather_element_resources e))
                     es
                     StringMap.empty
  | Attributed (_, e) -> gather_element_resources e
  | P (_, e) -> gather_element_resources e
  | Titled (_, e) -> gather_element_resources e
  | Link (_, page) -> (gather_page_resources page)
  | Link_ref _ -> StringMap.empty
  | Text _ -> StringMap.empty
  | Image (_, _, res) -> StringMap.singleton (resource_file_path res) res
  | Image_ref _ -> StringMap.empty
  | Identify (_, e) -> gather_element_resources e

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

let store_resource_map out_path resource_map =
  StringMap.iter
    (fun filename res ->
       Printf.printf "Rendering %s\n" filename;
       let s = Printf.sprintf "%s\n" (resource_data res) in
       write (out_path ^ "/" ^ filename) s)
    resource_map

let render out_path page =
  store_resource_map out_path (gather_website_resources page)

(* --- *)

let read_bin path =
  In_channel.with_open_bin path In_channel.input_all

let pages =
  with_ref (fun r1 ->
      with_ref (fun r2 ->
          (with_ref (fun r3 ->

               let gute_bild =
                 (make_resource "gutes_bild.png"
                                 (read_bin "./das-gute-bild.png"))

               and erste =
                 page_of_element
                   "Erste Seite"
                   (p [text "Ja moin";
                       link_ref "Zur zweiten Seite" r2])

               and zweite =
                 page_of_element
                   "Zweite"
                   ~ref:r2
                   (append
                      [
                        (p [text "Das ist der erste Absatz"]);
                        (p [(identify r1 (text "Tachsen auch"));
                            image_ref
                              "Ein gutes Bild"
                              r3;
                            link_ref "Zum ersten Abschnitt auf dieser Seite" r1
                           ])]) in

               make_website [erste; zweite; page_of_resource r3 gute_bild]))))

let seite2 =
  page_of_element
    "Seite 2"
    (text "Ja moin")

let example2 =
  page_of_element
    "Hauptseite"
    (p [text "Hier geht's zur nächsten Seite:";
        link "Seite 2" seite2])

let website1 =
  make_website [seite2; example2]


let unterseite main_ref =
  page_of_element
    "Unterseite"
    (p [(text "Hallole");
        link_ref "Zurück zur Hauptseite" main_ref
       ])

let hauptseite unterseite =
  page_of_element
    "Hauptseite"
    (append ~a:[a_style "background: green"]
       [(p [text "Hier geht's zur nächsten Seite:";
            image "Gutes Bild" (make_resource "logo.jpeg"
                                  (read_bin "./logo.jpeg"));
            link "Seite 2" unterseite])])

let website3 =
  with_ref (fun r ->
      let u = unterseite r in
      make_website [u; identify_page r (hauptseite u)])
