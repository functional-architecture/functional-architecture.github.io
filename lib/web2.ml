open Tyxml.Html


(* --- Ref --- *)

type id = string

type uri = string

type page_ref = {
  slug : string;
}

type element_ref = {
  page_ref : page_ref;
  id : id;
}

let element_ref_id ref = ref.id

type ref =
  | PageRef of page_ref
  | ElementRef of element_ref
  | ResourceRef of uri

let make_resource_ref uri = ResourceRef uri

let make_page_ref slug = PageRef { slug = slug }

let ref_of_page_ref pref = PageRef pref

let ref_url_path ref =
  match ref with
  | PageRef pref -> "/" ^ pref.slug ^ "/"
  | ElementRef eref -> "/" ^ eref.page_ref.slug ^ "/#" ^ eref.id
  | ResourceRef uri -> uri
                         
let ref_file_path ref =
  match ref with
  | PageRef pref -> pref.slug ^ "/index.html"
  | ElementRef _ -> assert(false)
  | ResourceRef uri -> uri

let resource_ref_of_page_ref pref =
  make_resource_ref (ref_file_path pref)


(* --- Resource --- *)

type resource =
  | Resource of string
  | Identified of uri * string

let make_resource data = Resource data

let identify_resource uri resource =
  match resource with
  | Resource data -> Identified (uri, data)
  | Identified (_, data) -> Identified (uri, data)

let resource_data resource =
  match resource with
  | Resource data -> data
  | Identified (_, data) -> data

let resource_ref resource =
  match resource with
  | Resource data -> ResourceRef (string_of_int @@ Hashtbl.hash data)
  | Identified (uri, _) -> ResourceRef uri

let resource_file_path resource =
  ref_file_path (resource_ref resource)


(* --- Element, Page, Website --- *)

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
  | Identify of element_ref * element

and page =
  | LiftElement of element
  | PageWithPageRef of (page_ref -> page)
  | Identified of page_ref * page
  | LiftResource of resource

and website =
  | Pages of page list
  | WebsiteWithPageRef of string option * (page_ref -> website)

let make_website pages = Pages pages

let h lvl =
  match lvl with
  | 1 -> Tyxml.Html.h1
  | 2 -> Tyxml.Html.h2
  | 3 -> Tyxml.Html.h3
  | 4 -> Tyxml.Html.h4
  | 5 -> Tyxml.Html.h5
  | _ -> Tyxml.Html.h6

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
                                      ~src:(ref_url_path (resource_ref resource))
                                      ~alt:alt
                                      ~a:attrs
                                      ()
  | Image_ref (attrs, alt, ref) -> Tyxml.Html.img
                                          ~src:(ref_url_path ref)
                                          ~alt:alt
                                          ~a:attrs
                                          ()
  | Identify (ref, (Fragment es)) -> Tyxml.Html.div ~a:[a_id (element_ref_id ref)] (List.map (html_of_element_block_h h_level) es)
  | Identify (ref, e) -> Tyxml.Html.div ~a:[a_id (element_ref_id ref)] [html_of_element_block_h h_level e]

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
                                      ~src:(ref_url_path (resource_ref resource))
                                      ~alt:alt
                                      ~a:attrs
                                      ()
  | Image_ref (attrs, alt, ref) -> Tyxml.Html.img
                                     ~src:(ref_url_path ref)
                                     ~alt:alt
                                     ~a:attrs
                                     ()
  | Identify (ref, (Fragment es)) -> Tyxml.Html.span ~a:[a_id (element_ref_id ref)] (List.map html_of_element_inline es)
  | Identify (ref, e) -> Tyxml.Html.span ~a:[a_id (element_ref_id ref)] [html_of_element_inline e]

and page_ref page =
  match page with
  | PageWithPageRef _ -> assert(false)
  | LiftResource res -> resource_ref res
  | Identified (pref, _) -> PageRef pref
  | LiftElement e -> make_page_ref (string_of_int (Hashtbl.hash e))

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

let page_of_element e = LiftElement e

let page_of_resource res = LiftResource res

let website_with_page_ref ?(slug = None) k : website =
  WebsiteWithPageRef (slug, k)

let identify_page ref page =
  match page with
  | Identified (_, inner_page) -> Identified (ref, inner_page)
  | _ -> Identified (ref, page)

let rec wrap_element f (e : element) =
  match e with
  | Fragment es -> Fragment (List.map (wrap_element f) es)
  | Attributed (attrs, e) -> Attributed (attrs, (wrap_element f e))
  | P (attrs, e) -> P (attrs, (wrap_element f e))
  | Titled (title, e) -> Titled (title, (wrap_element f e))
  | Link (s, page) -> Link (s, wrap_page f page)
  | Link_ref (s, ref) -> Link_ref (s, ref)
  | Text s -> Text s
  | Image (attrs, alt, resource) -> Image (attrs, alt, resource)
  | Image_ref (attrs, alt, ref) -> Image_ref (attrs, alt, ref)
  | Identify (ref, e) -> Identify (ref, wrap_element f e)

and wrap_page f (page: page) =
  match page with
  | PageWithPageRef k -> PageWithPageRef (fun r -> wrap_page f (k r))
  | LiftResource res -> LiftResource res
  | Identified (pref, inner_page) -> Identified (pref, wrap_page f inner_page)
  | LiftElement e -> LiftElement (f (wrap_element f e))

let rec wrap (website : website) f =
  match website with
  | WebsiteWithPageRef (strop, k) -> WebsiteWithPageRef (strop, fun r -> wrap (k r) f)
  | Pages pages -> Pages (List.map (wrap_page f) pages)


(* --- Rendering ---*)
module StringMap = Map.Make(String)

(** a.k.a. render *)
let rec string_of_page page =
  let string_of_html html =
    Format.asprintf "%a" (Tyxml.Html.pp ~indent:false ()) html in
  match page with
  | Identified (_, pg) -> string_of_page pg
  | LiftElement e -> (string_of_html
                        (html
                           (head
                              (Tyxml.Html.title (txt "TODO"))
                              [(meta ~a:[a_http_equiv "content-type"; a_content "text/html; charset=utf-8"] ())])
                           (body
                              [html_of_element_block e])))
  | PageWithPageRef k -> string_of_page (k { slug = "TODO" })
  | LiftResource res -> resource_data res

let resource_of_page page =
  let pref = page_ref page in
  identify_resource (ref_file_path pref) (make_resource (string_of_page page))

let rec gather_website_resources website : resource list =
  match website with
  | Pages pages -> List.concat_map gather_page_resources pages
  | WebsiteWithPageRef (slug, k) -> gather_website_resources (k { slug = Option.value slug ~default:"TODO"; })

and gather_page_resources page : resource list =
  let r = (resource_of_page page) in
  r ::
  (match page with
   | Identified (_, pg) -> gather_page_resources pg
   | LiftElement e -> gather_element_resources e
   | PageWithPageRef k -> gather_page_resources (k { slug = "TODO" })
   | LiftResource resource -> [resource])

and gather_element_resources e : resource list =
  match e with
  | Fragment es -> List.concat_map gather_element_resources es
  | Attributed (_, e) -> gather_element_resources e
  | P (_, e) -> gather_element_resources e
  | Titled (_, e) -> gather_element_resources e
  | Link (_, page) -> (gather_page_resources page)
  | Link_ref _ -> []
  | Text _ -> []
  | Image (_, _, res) -> [res]
  | Image_ref _ -> []
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

let store_resources out_path resources =
  List.iter
    (fun res ->
       let filename = resource_file_path res in
       Printf.printf "Rendering %s\n" filename;
       let s = Printf.sprintf "%s\n" (resource_data res) in
       write (out_path ^ "/" ^ filename) s)
    resources

let render out_path page =
  store_resources out_path (gather_website_resources page)

(* --- *)

let read_bin path =
  In_channel.with_open_bin path In_channel.input_all

let seite2 =
  page_of_element
    (text "Ja moin")

let example2 =
  page_of_element
    (p [text "Hier geht's zur nächsten Seite:";
        link "Seite 2" seite2])

let website1 =
  make_website [example2]


let unterseite main_ref =
  page_of_element
    (p [(text "Hallole");
        link_ref "Zurück zur Hauptseite" main_ref
       ])

let hauptseite unterseite =
  page_of_element
    (append ~a:[a_style "background: green"]
       [(p [text "Hier geht's zur nächsten Seite:";
            image "Gutes Bild" (identify_resource
                                  "/logo.jpg"
                                  (make_resource (read_bin "./logo.jpeg")));
            link "Seite 2" unterseite;
            link "Und gleich noch mal 2" unterseite;
           ])])

let website3 =
  wrap
    (website_with_page_ref
       ~slug:(Some "hauptseite")
       (fun r ->
          let u = unterseite (ref_of_page_ref r) in
          make_website [u; identify_page r (hauptseite u)]))
    (fun e ->
       append
         [(text "Hier ist noch ein Header"); e])
