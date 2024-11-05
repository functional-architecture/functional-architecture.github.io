open Tyxml.Html

type page = {
  route : string;
  content : doc;
}

let make_page route content = {
  route = route;
  content = content;
}

let page_route page = page.route

let page_content page = page.content

let page_filename page = "./" ^ page.route ^ "/index.html"

let page_link page = "/" ^ (page_route page)

let string_of_html html =
  Format.asprintf "%a" (Tyxml.Html.pp ~indent:false ()) html

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

let render_page page =
  let filename = page_filename page in
  Printf.printf "Rendering %s\n" filename;
  let s = Printf.sprintf "%s\n" (string_of_html page.content) in
  write filename s
