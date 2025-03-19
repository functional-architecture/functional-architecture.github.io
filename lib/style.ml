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

let fonts_directory = "assets/fonts"

let plex_serif style weight filename =
  Font.make_font "Plex" style weight (fonts_directory ^ "/" ^ filename)

let fonts = [
  plex_serif "normal" "100" "ibm-plex-serif-v19-latin-100.woff2";
  plex_serif "italic" "100" "ibm-plex-serif-v19-latin-100italic.woff2";
  plex_serif "normal" "200" "ibm-plex-serif-v19-latin-200.woff2";
  plex_serif "italic" "200" "ibm-plex-serif-v19-latin-200italic.woff2";
  plex_serif "normal" "300" "ibm-plex-serif-v19-latin-300.woff2";
  plex_serif "italic" "300" "ibm-plex-serif-v19-latin-300italic.woff2";
  plex_serif "normal" "400" "ibm-plex-serif-v19-latin-regular.woff2";
  plex_serif "italic" "400" "ibm-plex-serif-v19-latin-italic.woff2";
  plex_serif "normal" "500" "ibm-plex-serif-v19-latin-500.woff2";
  plex_serif "italic" "500" "ibm-plex-serif-v19-latin-500italic.woff2";
  plex_serif "normal" "600" "ibm-plex-serif-v19-latin-600.woff2";
  plex_serif "italic" "600" "ibm-plex-serif-v19-latin-600italic.woff2";
  plex_serif "normal" "700" "ibm-plex-serif-v19-latin-700.woff2";
  plex_serif "italic" "700" "ibm-plex-serif-v19-latin-700italic.woff2";
]

let font_decl fonts_with_refs =
  (String.concat
     "\n"
     (List.map Font.declare_font fonts_with_refs))

let css fonts_with_refs =
  (font_decl fonts_with_refs) ^
  {|
html, body {
    color: #333;
    margin: 0;
    padding: 0;
    font-size: 16px;
    line-height: 24px;
    font-family: 'Plex', serif;
}

a {
    color: #1b871b;
    text-decoration: none;
}

h1, h2, h3, h4, h5, h6 {
    margin: 0;
}

h1 {
    font-size: 84px;
    line-height: 90px;
    padding-bottom: 16px;
}

@media only screen and (max-width: 720px) {
    h1 {
        font-size: 64px;
        line-height: 72px;
    }
}

@media only screen and (max-width: 480px) {
    h1 {
        font-size: 32px;
        line-height: 38px;
    }
}

h5 {
    font-size: 16px;
    line-height: 24px;
    font-weight: bold;
}

div[role='doc-subtitle'] {
    font-size: 24px;
    line-height: 30px;
}

h2 {
    font-size: 32px;
    line-height: 42px;
}


h3 {
    font-size: 24px;
    line-height: 32px;
}

pre {
    overflow-x: auto;
    white-space: pre-wrap;
    word-break: break-all;
}
|}
