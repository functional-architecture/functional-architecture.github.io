open Tyxml.Html
open Funarch.Web5

let read_file file =
  In_channel.with_open_bin file In_channel.input_all

let highlight_js_data = (read_file "./js/highlight.min.js")

let highlight_js_java_data = (read_file "./js/languages/java.js")

let highlight_js_haskell_data = (read_file "./js/languages/haskell.js")

let highlight_js_ocaml_data = (read_file "./js/languages/ocaml.js")

let highlight_js_clojure_data = (read_file "./js/languages/clojure.js")

let highlight_js_scala_data = (read_file "./js/languages/scala.js")

let hl_js =
  let@ highlight_js = ("highlight.min.js", highlight_js_data) in
  let@ highlight_js_java = ("highlight_java.js", highlight_js_java_data) in
  let@ highlight_js_haskell = ("highlight_haskell.js", highlight_js_haskell_data) in
  let@ highlight_js_ocaml = ("highlight_ocaml.js", highlight_js_ocaml_data) in
  let@ highlight_js_clojure = ("highlight_clojure.js", highlight_js_clojure_data) in
  let@ highlight_js_scala = ("highlight_scala.js", highlight_js_scala_data) in
  pure
    (script
     ~a:[a_script_type `Module]
     (txt
        (Printf.sprintf
           "import hljs from '%s'
            import java from '%s'
            import haskell from '%s'
            import ocaml from '%s'
            import clojure from '%s'
            import scala from '%s'
            hljs.registerLanguage('java', java);
            hljs.registerLanguage('haskell', haskell);
            hljs.registerLanguage('ocaml', ocaml);
            hljs.registerLanguage('clojure', clojure);
            hljs.registerLanguage('scala', scala);
            hljs.highlightAll();"
           (deref highlight_js)
           (deref highlight_js_java)
           (deref highlight_js_haskell)
           (deref highlight_js_ocaml)
           (deref highlight_js_clojure)
           (deref highlight_js_scala))))

let highlight_css_data = read_file "./css/github.min.css"

let head =
  let@ hl_css = ("highlight.css", highlight_css_data) in
  let+ hl_js in
  (head
     (title (txt "Functional Software Architecture"))

     (List.concat
        [
          [
            (meta ~a:[a_http_equiv "content-type"; a_content "text/html; charset=utf-8"] ());
            (meta ~a:[a_name "viewport"; a_content "width=device-width, initial-scale=1.0"] ());
            (link ~rel:[`Icon] ~href:"favicon.svg" ~a:[a_mime_type "image/svg"] ());
            (link ~rel:[`Stylesheet] ~href:(deref hl_css) ());
            hl_js;
          ];
          (List.map Funarch.Font.link_preload_font Funarch.Style.fonts);
          [
            (style [txt ":root {--highlight-color: gray;}"]);
            (style [txt Funarch.Style.css]);
          ]
        ]))

let div_styled sty contents = div ~a:[a_style sty] contents

let vspace = div ~a:[a_style "height: 2em;"] []

let blocks ~id:_id contents = div ~a:[a_style "display: flex; gap: 3em; flex-wrap: wrap;"] contents

let block contents = div ~a:[a_style "width: 20em;"] contents

let menu children =
  ul ~a:[a_style "list-style-type: none; padding: 0; margin: 0; display: flex; gap: 2em; flex-wrap: wrap;"] children

let menu_item ?(is_active = false) child =
  li ~a:[a_style (if is_active then "font-weight: bold;" else "")] [
    child
  ]

let hdr ?(show_title=false) (highlight : [< `Overview | `Events | `Publications]) =
  header ~a:[a_style "padding: 0em 2em 2em 2em;"]
    [
      div_styled "display: flex; justify-content: center;" [
        div_styled "flex: 1;
                    padding: 2em 0;
                    max-width: 120em;
                    border-bottom: 1px solid #ccc;" [
          div_styled "display: flex; gap: 2em; justify-content: space-between; flex-wrap: wrap;" [
            menu [
              menu_item
                ~is_active:(highlight = `Overview)
                (a ~a:[a_href "/"] [txt "Overview"]);

              menu_item
                ~is_active:(highlight = `Events)
                (a ~a:[a_href "/events"] [txt "Events"]);

              menu_item
                ~is_active:(highlight = `Publications)
                (a ~a:[a_href "/publications"] [txt "Publications"]);

              menu_item
                (a ~a:[a_href "https://github.com/functional-architecture/functional-architecture.github.io"] [txt "GitHub"]);
            ];
            if show_title
              then strong [txt "Functional Software Architecture"]
              else txt "";
          ]]]]

let ftr ?(max_width="120em") () =
  footer ~a:[a_style "padding: 64px 32px; display: flex; justify-content: center;"] [
    div ~a:[a_style (Printf.sprintf "max-width: %s; flex: 1; padding-top: 32px; border-top: 1px solid gray;" max_width)] [
      div ~a:[a_style "display: flex; flex-wrap: wrap; gap: 32px;"]
        [
          div [
            div [
              txt "E-Mail: ";
              a ~a:[a_href "mailto:info@active-group.de"] [txt "info@active-group.de"]
            ];
            div [
              txt "Discuss: ";
              a ~a:[a_href "https://discuss.systems/@activegroupgmbh"] [txt "@activegroupgmbh@discuss.systems"]
            ];
            div [
              txt "X: ";
              a ~a:[a_href "https://twitter.com/activegroupgmbh"] [txt "x.com/activegroupgmbh"]
            ];
          ];

          div [
            div [
              txt "Telefon: ";
              a ~a:[a_href "tel:+49707170896-0"] [txt "+49 7071 70896-0"]
            ];
            div [
              txt "Fax: ";
              a ~a:[a_href "tel:+49707170896-89"] [txt "+49 7071 70896-89"]
            ];
          ];

          div [
            txt "Active Group GmbH";
            br ();
            txt "Hechinger Straße 12/1";
            br ();
            txt "72072 Tübingen";
          ]]]]

let toc =
  div_styled "font-size: 14px; width: 20rem;" [
    div_styled "border-top: 1px solid gray;
                          border-bottom: 1px solid gray;
                          padding: 1em;" [
      h3 ~a:[a_style "font-size: 18px;"] [txt "Table of Contents"];

      ol [
        li [a ~a:[a_href "#values"] [txt "Values"]];
        li [a ~a:[a_href "#principles"] [txt "Principles"]];
        li [a ~a:[a_href "#patterns"] [txt "Patterns, Tools, and Techniques"]];
        li [a ~a:[a_href "#faq"] [txt "FAQ"]];
      ]]]

let pr_value_short_block v =
  let open Funarch.Values in
  block [
    h3 [txt v.title];
    p [txt v.short]]

let pr_value_blocks vs =
  blocks ~id:"values" (List.map pr_value_short_block vs)

let centered_with_footer ?(max_width="120em") content = 
  div [
    div_styled "display: flex; justify-content: center;" [
      div_styled (Printf.sprintf
                    "max-width: %s; padding: 4em 2em;"
                    max_width)
        [
          content
        ]
    ];
    vspace;
    ftr ()]

let page_of_principle (pr : Funarch.Principles.principle) =
  let open Funarch.Principles in
  (body
     [hdr ~show_title:true `Overview;
      (centered_with_footer
         ~max_width: "50em"
         (div
            [(h1 [txt pr.title]);
             div ~a:[a_role ["doc-subtitle"]]
               [txt "A";
                txt " ";
                a ~a:[a_href "/"] [txt "Functional Software Architecture"];
                txt " ";
                txt "Principle"
               ];
             vspace;
             match pr.long with
             | Some desc -> desc
             | None -> txt "TODO"]))])

let pr_principle_short_block (principle, page_ref) =
  let open Funarch.Principles in
  block [
    h3 [txt principle.title];
    p [txt principle.short];
    a ~a:[a_href (deref page_ref)] [
      txt "→ ";
      txt "More";
    ]
  ]

let pr_principles_blocks ps =
  blocks ~id:"principles" (List.map pr_principle_short_block ps)

let page_of_pattern (pattern : Funarch.Patterns.pattern) =
  let open Funarch.Patterns in
  (body
     [hdr ~show_title:true `Overview;
      (centered_with_footer
         ~max_width: "50em"
         (div
            [(h1 [txt pattern.title]);
             div ~a:[a_role ["doc-subtitle"]]
               [txt "A";
                txt " ";
                a ~a:[a_href "/"] [txt "Functional Software Architecture"];
                txt " ";
                txt "Pattern"
               ];
             vspace;
             pattern.long
            ]))])

let pr_pattern_short_block (pattern, ref) =
  let open Funarch.Patterns in
  block [
    h3 [txt pattern.title];
    pattern.short;
    a ~a:[a_href (deref ref)] [
      txt "→ ";
      txt "More";
    ]]

let pr_patterns_blocks ps =
  blocks ~id:"patterns" (List.map pr_pattern_short_block ps)

let pr_faq f =
  let open Funarch.Faqs in
  div [
    h5 [txt f.question];
    p [txt f.answer]
  ]

let pr_faqs fs =
  List.map pr_faq fs


let the_values = pr_value_blocks Funarch.Values.values

let the_principles principles =
  div [
    h2 ~a:[a_id "principles"] [txt "Principles"];
    p [txt "We strive for the values described above. We do so by
            following this set of principles."];
    vspace;
    pr_principles_blocks principles;
  ]

let the_patterns patterns =
  div [
    h2 ~a:[a_id "patterns"] [txt "Patterns, Tools, and Techniques"];
    p [txt "We follow the principles described above by \
            employing some of the following techniques."];
    vspace;
    pr_patterns_blocks patterns;
  ]

let the_faqs =
  div ~a:[a_style "display: flex; flex-direction: column; gap: 1em; max-width: 50em;"] [
    h2 ~a:[a_id "faq"] [txt "Frequently Asked Questions"];
    vspace;
    div ~a:[a_style "display: flex; flex-direction: column; gap: 1em;"]
      (pr_faqs Funarch.Faqs.faqs);
  ]


let main_body principles patterns = (body [
    hdr `Overview;
    centered_with_footer
    (
      div_styled "display: flex;
                  flex-direction: column;
                  gap: 8em;" [
        div_styled "display: flex; flex-direction: column; gap: 2em;" [
          div_styled "display: flex; gap: 3em; align-items: end; flex-wrap: wrap;" [
            div_styled "max-width: 43em;" [
              h1 [(txt "Functional Software Architecture")];
              div ~a:[a_role ["doc-subtitle"]]
                [txt "Functional programming in the large"];
              vspace;
              p [
                i [txt "Functional Software Architecture"];
                txt "refers to methods of construction and structure \
                     of large and long-lived software projects that \
                     are implemented in functional languages and \
                     released to real users, typically in industry."
              ];
              p [
                txt "We strive for ..."
              ]];
            toc
          ];
        ];
        the_values;
        the_principles principles;
        the_patterns patterns;
        the_faqs;
      ]
    )])

let funarch_2024 = (Funarch.Markdown.from_markdown_file "./events/funarch-2024/index.md")
let funarch_2023 = (Funarch.Markdown.from_markdown_file "./events/funarch-2023/index.md")

let events =
  let$ ref_2024 = 1 in
  let$ ref_2023 = 2 in
  (case
     [("funarch-2023",
       refer
         ref_2023
         (pure
            (body
             [hdr ~show_title:true `Events;
              (centered_with_footer
                 ~max_width: "50em"
                 (div
                    [(h1 [txt "FUNARCH 2023"]);
                     div ~a:[a_role ["doc-subtitle"]] [txt "Functional Software Architecture Workshop co-located with ICFP 2023"];
                     vspace;
                     funarch_2023
                    ]))])));
      ("funarch-2024",
       refer ref_2024
         (pure
            (body
             [hdr ~show_title:true `Events;
              (centered_with_footer
                 ~max_width: "50em"
                 (div
                    [(h1 [txt "FUNARCH 2024"]);
                     div ~a:[a_role ["doc-subtitle"]] [txt "Functional Software Architecture Workshop co-located with ICFP 2024"];
                     vspace;
                     funarch_2024
                    ]))])))]
     (* default / *)
     (pure
        (body
         [hdr ~show_title:true `Events;
          (centered_with_footer
             ~max_width: "50em"
             (div
                [(h1 [txt "Events"]);
                 div ~a:[a_role ["doc-subtitle"]]
                   [a ~a:[a_href ".."] [txt "Functional Software Architecture"]];
                 vspace;
                 a ~a:[a_href (deref ref_2023)] [txt "FUNARCH 2023"];
                 a ~a:[a_href (deref ref_2024)] [txt "FUNARCH 2024"];
                ]))])))

let publications_page =
  pure
    (body
       [hdr ~show_title:true `Publications;
        (centered_with_footer
           ~max_width: "50em"
           (div
              [(h1 [txt "Publications"]);
               div ~a:[a_role ["doc-subtitle"]] [txt "Functional Software Architecture"];
               vspace;
               txt "TODO";
              ]))])

let rec refify' xs k acc =
  match xs with
  | [] -> k (List.rev acc)
  | (x :: xs) ->
    with_ref (fun r -> refify' xs k (List.cons (x, r) acc))

let refify (xs : 'a list) (k : ('a * ref) list -> 'b web) : 'b web =
  refify' xs k []

let website =
  map2
    html
    head
    (refify
       Funarch.Principles.principles
       (fun principles ->
          refify
            Funarch.Patterns.patterns
            (fun patterns ->
              case
                (List.concat
                   [[("publications", publications_page); ("events", events)];
                    (List.map
                       (fun (pr, r) ->
                          (pr.Funarch.Principles.route, (refer r (pure (page_of_principle pr)))))
                       principles);
                    (List.map
                       (fun (pat, r) ->
                          (pat.Funarch.Patterns.route, (refer r (pure (page_of_pattern pat)))))
                       patterns);
                   ])
                (pure (main_body principles patterns)))))

let pr_html x = Format.asprintf "%a" (Tyxml.Html.pp ~indent:false ()) x

let out_dir = "out"

let () =
  Printf.printf "Functional Software Architecture\n";
  if not (Sys.file_exists out_dir)
      then Sys.mkdir out_dir 0o777;
  Sys.chdir out_dir;
  render (map pr_html website);
  List.iter Funarch.Font.store_font Funarch.Style.fonts;
