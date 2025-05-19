open Tyxml.Html

let convert_quotes s =
  Str.global_replace (Str.regexp "\"\\([^\"]*\\)\"") "“\\1”" s

(* TODO: This is a mess because I don't understand variant types *)

let rec html_from_markdown_inline (md : Omd.attributes Omd.inline)
  : Html_types.phrasing_without_interactive elt =
  match md with
  | Link (_attr, _link) -> assert false
  | Concat (_attr, children) -> span (List.map html_from_markdown_inline_with_a children)
  | Text (_attr, s) -> txt (convert_quotes s)
  | Emph (_attr, child) -> em [(html_from_markdown_inline_with_a child)]
  | Strong (_attr, child) -> strong [(html_from_markdown_inline_with_a child)]
  | Code (_attr, str) -> code [(txt str)]
  | Hard_break _attr -> br ()
  | Soft_break _attr -> txt " "
  | Image (_attr, link) -> img ~src:link.destination ~alt:"TODO" ()
  | Html (_attr, _raw) -> txt "TODO"

and html_from_markdown_inline_with_a (md : Omd.attributes Omd.inline) =
  match md with
  | Concat (_attr, children) -> span (List.map html_from_markdown_inline_with_a children)
  | Text (_attr, s) -> txt (convert_quotes s)
  | Emph (_attr, child) -> em [(html_from_markdown_inline_with_a child)]
  | Strong (_attr, child) -> strong [(html_from_markdown_inline_with_a child)]
  | Code (_attr, str) -> code [(txt str)]
  | Hard_break _attr -> br ()
  | Soft_break _attr -> txt " "
  | Link (_attr, link) -> Tyxml.Html.a ~a:[a_href link.destination] [(html_from_markdown_inline link.label)]
  | Image (_attr, link) -> img ~src:link.destination ~alt:"TODO" ()
  | Html (_attr, _raw) -> txt "TODO"

and html_from_markdown_inline_cell (md : Omd.attributes Omd.inline) : [> `Br | `Code | `Em | `Img | `PCDATA | `Span | `Strong ] elt =
  match md with
  | Link (_attr, _link) -> assert false
  | Concat (_attr, children) -> span (List.map html_from_markdown_inline_with_a children)
  | Text (_attr, s) -> txt (convert_quotes s)
  | Emph (_attr, child) -> em [(html_from_markdown_inline_with_a child)]
  | Strong (_attr, child) -> strong [(html_from_markdown_inline_with_a child)]
  | Code (_attr, str) -> code [(txt str)]
  | Hard_break _attr -> br ()
  | Soft_break _attr -> txt " "
  | Image (_attr, link) -> img ~src:link.destination ~alt:"TODO" ()
  | Html (_attr, _raw) -> txt "TODO"

let h = function
  | 1 -> h1 ~a:[a_style "margin-top: 1em;"]
  | 2 -> h2 ~a:[a_style "margin-top: 1em;"]
  | 3 -> h3 ~a:[a_style "margin-top: 1em;"]
  | 4 -> h4 ~a:[a_style "margin-top: 1em;"]
  | 5 -> h5 ~a:[a_style "margin-top: 1em;"]
  | _ -> h6 ~a:[a_style "margin-top: 1em;"]

let html_of_list_type = function
  | Omd.Ordered _ -> ol
  | Omd.Bullet _ -> ul

let is_front_matter h_level h_children =
  match h_children with
  | Omd.Concat (_, Omd.Text (_, s) :: _) -> h_level = 2
                                            && List.length (String.split_on_char ':' s)
                                               = 2
  | _ -> false

let rec html_from_markdown_block (md : Omd.attributes Omd.block)
  : [>] elt =

  let open Omd in
  match md with
  | Paragraph (_attr, children) -> p [(html_from_markdown_inline_with_a children)]
  | List (_attr, list_type, _list_spacing, elemss) -> (html_of_list_type list_type)
                                                        (List.map
                                                           (fun elems -> li (List.map html_from_markdown_block elems))
                                                           elemss)
  | Blockquote (_attr, children) -> blockquote (List.map html_from_markdown_block children)
  | Thematic_break _attr -> hr ()
  | Heading (_attr, lvl, children) when is_front_matter lvl children -> txt ""
  | Heading (_attr, lvl, children) -> (h lvl) [(html_from_markdown_inline_with_a children)]
  | Code_block (_attr, label, content) -> pre ~a:[a_style "white-space: pre-wrap"] [code ~a:[a_class ["language-" ^ label]] [txt content]]
  | Html_block (_attr, raw) -> Unsafe.data raw
  | Definition_list (_attr, _definitions) -> txt "TODO"
  | Table (_attr, _header, body) -> table (List.map
                                             (fun row ->
                                               (tr
                                                  (List.map
                                                     (fun cell -> (td [(html_from_markdown_inline_cell cell)]))
                                                  row)))
                                             body)


let html_from_markdown (mds : Omd.doc) =
  div (List.map html_from_markdown_block mds)

let from_markdown_file path =
  let open Omd in
  let md = of_channel (open_in path) in
  (html_from_markdown md)

let read_file file =
  In_channel.with_open_bin file In_channel.input_all

let rec replace_params s formal_params actual_params =
  match formal_params with
  | [] -> s
  | (p :: ps) -> (let actual = List.hd actual_params in
                  let actuals = List.tl actual_params in
                  let s' = Str.global_replace (Str.regexp p) actual s in
                  (replace_params s' ps actuals))

let function_of_parameterized_markdown path formal_params =
  let open Omd in
  let s = read_file path in
  fun actual_params ->
    assert ((List.length formal_params) = (List.length actual_params));
    let s' = (replace_params s formal_params actual_params) in
    let md = of_string s' in
    (html_from_markdown md)
