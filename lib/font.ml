open Web5

type font = {
  font_family : string;
  font_style : string;
  font_weight : string;
  data : string;
}

let read_file file =
  In_channel.with_open_bin file In_channel.input_all

let make_font family style weight file_path =
  {
    font_family = family;
    font_style = style;
    font_weight = weight;
    data = read_file file_path;
  }

let font_output_file_name font =
  font.font_family ^ "_" ^ font.font_style ^ "_" ^ font.font_weight ^ "_" ^ string_of_int (Hashtbl.hash font.data) ^ ".woff2"

let declare_font (font, ref) : string =
  "@font-face {\n" ^
  "  font-display: swap;\n" ^
  "  font-family: '" ^ font.font_family ^ "';\n" ^
  "  font-style: " ^ font.font_style ^ ";\n" ^
  "  font-weight: " ^ font.font_weight ^ ";\n" ^
  "  src: url('" ^ (deref ref) ^ "') format(woff2);\n" ^
  "}\n"

let link_preload_font ref =
  let open Tyxml.Html in
  link
    ~rel:[`Preload]
    ~href:(deref ref)
    ~a:[a_mime_type "font/woff2";
        a_crossorigin `Anonymous;
        Tyxml.Html.Unsafe.string_attrib "as" "font"]
    ()

let use_font_family font = "font-family: '" ^ font.font_family ^ "', serif" ^ ";"
