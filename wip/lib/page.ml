open Tyxml.Html

type page = {
  filename : string;
  content : doc;
}

let link page = page.filename

let string_of_html html =
  Format.asprintf "%a" (Tyxml.Html.pp ~indent:true ()) html

let render_page page =
  Printf.printf "Rendering %s\n" page.filename;
  let oc = open_out page.filename in
  Printf.fprintf oc "%s\n" (string_of_html page.content);
