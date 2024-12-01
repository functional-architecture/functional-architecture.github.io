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
  | CallWithCurrentPageRef of (page_ref -> element)
  | HeadTitled of string * element

and page =
  | LiftElement of string option * element
  | PageWithPageRef of (page_ref -> page)
  | Identified of page_ref * page
  | LiftResource of resource

and website =
  | Pages of page list
  | WebsiteWithPageRef of string option * (page_ref -> website)
  | And of website list

let make_website pages = Pages pages

let h lvl =
  match lvl with
  | 1 -> Tyxml.Html.h1
  | 2 -> Tyxml.Html.h2
  | 3 -> Tyxml.Html.h3
  | 4 -> Tyxml.Html.h4
  | 5 -> Tyxml.Html.h5
  | _ -> Tyxml.Html.h6

let rec html_of_element_block_h current_page_ref h_level element =
  match element with
  | Fragment _ -> assert(false)
  | Attributed (attrs, (Fragment es)) -> Tyxml.Html.div ~a:attrs (List.map (html_of_element_block_h current_page_ref h_level) es)
  | Attributed (attrs, e) -> Tyxml.Html.div ~a:attrs [(html_of_element_block_h current_page_ref h_level e)]
  | P (attrs, (Fragment es)) -> Tyxml.Html.p ~a:attrs (List.map (html_of_element_inline current_page_ref) es)
  | P (attrs, e) -> Tyxml.Html.p ~a:attrs [(html_of_element_inline current_page_ref e)]
  | Titled (title, e) -> Tyxml.Html.div [
      (h h_level) [Tyxml.Html.txt title];
      (html_of_element_block_h current_page_ref (h_level + 1) e)
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
  | Identify (ref, (Fragment es)) -> Tyxml.Html.div ~a:[a_id (element_ref_id ref)] (List.map (html_of_element_block_h current_page_ref h_level) es)
  | Identify (ref, e) -> Tyxml.Html.div ~a:[a_id (element_ref_id ref)] [html_of_element_block_h current_page_ref h_level e]
  | CallWithCurrentPageRef k -> html_of_element_block_h current_page_ref h_level (k current_page_ref)
  | HeadTitled (_s, e) -> html_of_element_block_h current_page_ref h_level e

and html_of_element_inline (current_page_ref : page_ref) element =
  match element with
  | Fragment _ -> assert(false)
  | Attributed (attrs, (Fragment es)) -> Tyxml.Html.span ~a:attrs (List.map (html_of_element_inline current_page_ref) es)
  | Attributed (attrs, e) -> Tyxml.Html.span ~a:attrs [(html_of_element_inline current_page_ref e)]
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
  | Identify (ref, (Fragment es)) -> Tyxml.Html.span ~a:[a_id (element_ref_id ref)] (List.map (html_of_element_inline current_page_ref) es)
  | Identify (ref, e) -> Tyxml.Html.span ~a:[a_id (element_ref_id ref)] [html_of_element_inline current_page_ref e]
  | CallWithCurrentPageRef k -> html_of_element_inline current_page_ref (k current_page_ref)
  | HeadTitled (_s, e) -> html_of_element_inline current_page_ref e

and page_ref page =
  match page with
  | PageWithPageRef _ -> assert(false)
  | LiftResource res -> resource_ref res
  | Identified (pref, _) -> PageRef pref
  | LiftElement (slug, e) -> make_page_ref (Option.value slug ~default:(string_of_int (Hashtbl.hash e)))

let html_of_element_block current_page_ref = html_of_element_block_h current_page_ref 1

let append ?(a = []) elements = Attributed (a, (Fragment elements))
let p ?(a = []) elements = P (a, (Fragment elements))
let text s = Text s
let image ?(a = []) alt resource = Image (a, alt, resource)
let image_ref ?(a = []) alt ref = Image_ref (a, alt, ref)
let titled title elements = Titled (title, (Fragment elements))
let link (s : string) page = Link (s, page)
let link_ref (s : string) ref = Link_ref (s, ref)
let identify ref element = Identify (ref, element)
let call_with_current_page_ref k = CallWithCurrentPageRef k

let page_of_element ?(slug = "") e =
  let mslug = if slug = ""
                 then None
                 else Some slug in
  LiftElement (mslug, e)

let page_of_resource res = LiftResource res

let website_with_page_ref ?(slug = "") k : website =
  let mslug = if slug = ""
                 then None
                 else Some slug in
  WebsiteWithPageRef (mslug, k)

let website_with_page_refs_3
    ?(slug1 = "")
    ?(slug2 = "")
    ?(slug3 = "")
    k
  = website_with_page_ref
    ~slug:slug1
    (fun r1 ->
       website_with_page_ref
         ~slug:slug2
         (fun r2 ->
            (website_with_page_ref
               ~slug:slug3
               (k r1 r2))))

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
  | CallWithCurrentPageRef k -> CallWithCurrentPageRef (fun r -> wrap_element f (k r))
  | HeadTitled (s, e) -> HeadTitled (s, wrap_element f e)

and wrap_page f (page: page) =
  match page with
  | PageWithPageRef k -> PageWithPageRef (fun r -> wrap_page f (k r))
  | LiftResource res -> LiftResource res
  | Identified (pref, inner_page) -> Identified (pref, wrap_page f inner_page)
  | LiftElement (slug, e) -> LiftElement (slug, (f (wrap_element f e)))

let rec wrap (website : website) f =
  match website with
  | WebsiteWithPageRef (strop, k) -> WebsiteWithPageRef (strop, fun r -> wrap (k r) f)
  | Pages pages -> Pages (List.map (wrap_page f) pages)
  | And websites -> And (List.map (fun w -> wrap w f) websites)


(* --- Rendering ---*)
module StringMap = Map.Make(String)

let next_slug x = string_of_int (Hashtbl.hash x)

let next_page_ref x = { slug = (next_slug x)}

(** a.k.a. render *)
let rec string_of_page current_page_ref title page =
  let string_of_html html =
    Format.asprintf "%a" (Tyxml.Html.pp ~indent:false ()) html in
  match page with
  | Identified (_, pg) -> string_of_page current_page_ref title pg
  | LiftElement (_slug, e) -> (string_of_html
                                (html
                                   (head
                                      (Tyxml.Html.title (txt title))
                                      [(meta ~a:[a_http_equiv "content-type"; a_content "text/html; charset=utf-8"] ())])
                                   (body
                                      [html_of_element_block current_page_ref e])))
  | PageWithPageRef k -> string_of_page current_page_ref title (k (next_page_ref current_page_ref))
  | LiftResource res -> resource_data res

let resource_of_page current_page_ref title page =
  let pref = page_ref page in
  identify_resource (ref_file_path pref) (make_resource (string_of_page current_page_ref title page))

let rec gather_website_resources website : resource list =
  match website with
  | Pages pages -> (List.fold_right
                      (fun page acc ->
                         List.append
                           acc
                           (gather_page_resources { slug = (next_slug page) } "Untitled" page))
                      pages
                      [])
  | WebsiteWithPageRef (slug, k) -> gather_website_resources (k { slug = Option.value slug ~default:(next_slug k); })
  | And websites -> List.concat_map gather_website_resources websites

and gather_page_resources (current_page_ref : page_ref) (title : string) page : resource list =
  let r = (resource_of_page current_page_ref title page) in
  r ::
  (match page with
   | Identified (pref, pg) -> gather_page_resources pref title pg
   | LiftElement (_slug, e) -> gather_element_resources current_page_ref title e
   | PageWithPageRef k -> gather_page_resources current_page_ref title (k (next_page_ref current_page_ref))
   | LiftResource resource -> [resource])

and gather_element_resources (current_page_ref : page_ref) title e : resource list =
  match e with
  | Fragment es -> List.concat_map (gather_element_resources current_page_ref title) es
  | Attributed (_, e) -> gather_element_resources current_page_ref title e
  | P (_, e) -> gather_element_resources current_page_ref title e
  | Titled (_, e) -> gather_element_resources current_page_ref title e
  | Link (_, page) -> (gather_page_resources current_page_ref title page)
  | Link_ref _ -> []
  | Text _ -> []
  | Image (_, _, res) -> [res]
  | Image_ref _ -> []
  | Identify (_, e) -> gather_element_resources current_page_ref title e
  | CallWithCurrentPageRef k -> gather_element_resources current_page_ref title (k current_page_ref)
  | HeadTitled (_, e) -> gather_element_resources current_page_ref title e

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
    ~slug:"unterseite"
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
       ~slug:"hauptseite"
       (fun r ->
          let u = unterseite (ref_of_page_ref r) in
          make_website [u; identify_page r (hauptseite u)]))
    (fun e ->
       append
         [(text "Hier ist noch ein Header"); e])

let menu entries =
  append
    (List.map
       (fun (ref, title) ->
          call_with_current_page_ref
            (fun current_ref ->
               let active = current_ref == ref in
               p ~a:(if active then [a_style "background: red"] else [])
                 [link_ref title (ref_of_page_ref ref)]))
       entries)

let overview_page = page_of_element (text "Overview")
let events_page = page_of_element (text "Events")
let publications_page = page_of_element (text "Publications")

(* ... *)

type new_ref_request = {
  slug : string;
}

let ( let* ) new_ref_request k =
  website_with_page_ref ~slug:new_ref_request.slug k

let new_ref slug = {
  slug = slug;
}

let website4 =
  let* overview_ref = new_ref "overview" in
  let* events_ref = new_ref "events" in
  let* publications_ref = new_ref "publications" in
  wrap
    (make_website [identify_page overview_ref overview_page;
                   identify_page events_ref events_page;
                   identify_page publications_ref publications_page;])
    (fun e ->
       append
         [menu
            [(overview_ref, "Overview");
             (events_ref, "Events");
             (publications_ref, "Publications");];
          e])


let c = page_of_element (text "C")
let website5 = And [website4; make_website [c]]


let foo x =
  match x with
  | `A -> "a"
  | `B -> "b"

let is_a_or_b x =
  match x with
  | `A -> true
  | `B -> true
  | _ -> false

type ('a, 'b) lens = {
  get : 'a -> 'b;
  set : 'a -> 'b -> 'a;
}

let fst = {
  get = List.hd;
  set = fun l x -> match l with
    | [] -> []
    | _ :: xs -> x :: xs
}

type path =
  | Emp
  | Cns of string * path

let rec string_of_path =
  function
  | Emp -> ""
  | Cns (s, p) -> s ^ "/" ^ (string_of_path p)

let rec cat_path p1 p2 =
  match p1 with
  | Emp -> p2
  | Cns (s, p1r) -> Cns (s, cat_path p1r p2)

type it =
  | Text : string -> it
  | And : it * it -> it
  | Match : (string * it) list -> it
  | Link : path -> it

let ex1 =
  Match
    [("A", Link (Cns ("B", Emp)));
     ("B", Link (Cns ("A", Emp)))]

let rec render_it =
  function
  | path, Text s -> StringMap.singleton (string_of_path path) s
  | path, And (it1, it2) ->
    StringMap.merge
      (fun _k left right ->
         Option.bind left
           (fun l ->
              Option.bind right
                (fun r ->
                   Some (l ^ r))))
      (render_it (path, it1))
      (render_it (path, it2))
  | path, Link p -> StringMap.singleton (string_of_path path) (string_of_path (cat_path path p))
  | _path, Match [] -> StringMap.empty
  | _path, Match ((seg, it1) :: cases) -> 

type _ item =
  | Text : string -> 'a item
  | And : 'a item * 'a item -> 'a item
  | Focus : ('a, 'b) lens * 'b item -> 'a item
  | Select : ('a -> 'x) * ('x * 'a item) list -> 'a item
  | Link : 'a * string -> 'a item

let rec resources_of_item : type a. ((a -> string) * a item) -> string StringMap.t =
  function
  | _ctx, Text s -> StringMap.singleton "" s
  | ctx, And (i1, i2) -> StringMap.merge
                      (fun _k left right ->
                         Option.bind left
                           (fun l ->
                              Option.bind right
                                (fun r ->
                                   Some (l ^ r))))
                      (resources_of_item (ctx, i1))
                      (resources_of_item (ctx, i2))
  | ctx, Focus (l, i1) -> resources_of_item (l.get ctx, i1)
  | _ctx, Select (_f, _cases) -> assert(false)
  | ctx, Link(target, _s) -> StringMap.singleton "" ("LINK: " ^ (ctx target))


let one_of_two (x, _) = x
let two_of_two (_, y) = y

let one_of_two_lens = {
  get = one_of_two;
  set = fun (_, y) xx -> (xx, y)
}

let two_of_two_lens = {
  get = two_of_two;
  set = fun (x, _) yy -> (x, yy)
}

let x = Focus (two_of_two_lens, (And ((Text "moin"), (Link (`A, "Nach A")))))

let y =
  Select
    (one_of_two,
     [(`Menu, x);
      (`C, And (Text "C", Link ((`Menu, `A), "To A!")))])

let z =
  Or
    [(`A, (Link (`B, "Nach B")));
     (`B, (Link (`A, "Nach A")))])
