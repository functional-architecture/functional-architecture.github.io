type resource = {
  dest_path : string;
  data : string;
}

let resource_filename resource = "./" ^ resource.dest_path

let resource_link resource = "/" ^ resource.dest_path

let read_file file =
  In_channel.with_open_bin file In_channel.input_all

let make_resource src_path dest_path =
  {
    dest_path = dest_path;
    data = read_file src_path;
  }

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

let render_resource resource =
  let filename = resource_filename resource in
  Printf.printf "Rendering %s\n" filename;
  write filename resource.data
