open Tyxml.Html

type page = {
  filename : string;
  content : doc;
}

let link page = "/" ^ page.filename

let string_of_html html =
  Format.asprintf "%a" (Tyxml.Html.pp ~indent:true ()) html

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
  Printf.printf "Rendering %s\n" page.filename;
  let s = Printf.sprintf "%s\n" (string_of_html page.content) in
  write page.filename s
