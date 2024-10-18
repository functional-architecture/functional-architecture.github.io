open Tyxml.Html

let rec html_from_markdown_inline (md : Omd.attributes Omd.inline)
  : Html_types.phrasing_without_interactive elt =
  match md with
  | Link (_attr, _link) -> assert false
  | Concat (_attr, children) -> span (List.map html_from_markdown_inline_with_a children)
  | Text (_attr, s) -> txt s
  | Emph (_attr, child) -> em [(html_from_markdown_inline_with_a child)]
  | Strong (_attr, child) -> strong [(html_from_markdown_inline_with_a child)]
  | Code (_attr, str) -> code [(txt str)]
  | Hard_break _attr -> br ()
  | Soft_break _attr -> txt "\n"
  | Image (_attr, _link) -> txt "TODO"
  | Html (_attr, _raw) -> txt "TODO"

and html_from_markdown_inline_with_a (md : Omd.attributes Omd.inline) =
  match md with
  | Concat (_attr, children) -> span (List.map html_from_markdown_inline_with_a children)
  | Text (_attr, s) -> txt s
  | Emph (_attr, child) -> em [(html_from_markdown_inline_with_a child)]
  | Strong (_attr, child) -> strong [(html_from_markdown_inline_with_a child)]
  | Code (_attr, str) -> code [(txt str)]
  | Hard_break _attr -> br ()
  | Soft_break _attr -> space ()
  | Link (_attr, link) -> Tyxml.Html.a ~a:[a_href link.destination] [(html_from_markdown_inline link.label)]
  | Image (_attr, _link) -> txt "TODO"
  | Html (_attr, _raw) -> txt "TODO"

let h = function
  | 1 -> h1
  | 2 -> h2
  | 3 -> h3
  | 4 -> h4
  | 5 -> h5
  | _ -> h6

let rec html_from_markdown_block (md : Omd.attributes Omd.block)
  : [>] elt =

  let open Omd in
  match md with
  | Paragraph (_attr, children) -> p [(html_from_markdown_inline_with_a children)]
  | List (_, _, _, _) -> txt "TODO"
  | Blockquote (_attr, children) -> blockquote (List.map html_from_markdown_block children)
  | Thematic_break _attr -> hr ()
  | Heading (_attr, lvl, children) -> (h lvl) [(html_from_markdown_inline_with_a children)]
  | Code_block (_attr, _label, code) -> pre [txt code]
  | Html_block (_attr, _raw) -> txt "TODO"
  | Definition_list (_attr, _definitions) -> txt "TODO"
  | Table (_attr, _header, _body) -> table []

let html_from_markdown (mds : Omd.doc) =
  div (List.map html_from_markdown_block mds)

let from_markdown_file file =
  let open Omd in
  let md = of_channel file in
  let sexp = to_sexp md in
  print_endline sexp;
  (html_from_markdown md)
