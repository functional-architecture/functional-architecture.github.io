type font = {
  font_family : string;
  font_style : string;
  font_weight : string;
  src : string;
}

let fonts_directory = "../../assets/fonts"

let plex_serif style weight filename =
  {
    font_family = "IBM Plex serif";
    font_style = style;
    font_weight = weight;
    src = "url('" ^ fonts_directory ^ "/" ^ filename ^ "') format('woff2')"
  }

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

let pr_font font =
  "@font-face {\n" ^
  "  font-display: swap;\n" ^
  "  font-family: '" ^ font.font_family ^ "';\n" ^
  "  font-style: " ^ font.font_style ^ ";\n" ^
  "  font-weight: " ^ font.font_weight ^ ";\n" ^
  "  src: " ^ font.src ^ ";\n" ^
  "}\n"

let font_decl =
  String.concat "\n"
  @@ List.map pr_font fonts

let css =
  font_decl ^
  {|
html, body {
    margin: 0;
    padding: 0;
    font-size: 16px;
    line-height: 24px;
    font-family: 'IBM Plex Serif', serif;
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
    font-size: 48px;
    line-height: 52px;
}


h3 {
    font-size: 24px;
    line-height: 32px;
}
|}
