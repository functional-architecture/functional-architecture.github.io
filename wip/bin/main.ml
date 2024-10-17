open Tyxml.Html

let link_preload_font s =
  link
    ~rel:[`Preload]
    ~href:s
    ~a:[a_mime_type "font/woff2";
        a_crossorigin `Anonymous]
    ()

let main_head =
  (head (title (txt "Functional Software Architecture")) [
      (meta ~a:[a_http_equiv "content-type"; a_content "text/html; charset=utf-8"] ());
      (meta ~a:[a_name "viewport"; a_content "width=device-width, initial-scale=1.0"] ());
      (link ~rel:[`Icon] ~href:"favicon.svg" ~a:[a_mime_type "image/svg"] ());
      (link_preload_font "assets/fonts/ibm-plex-serif-v19-latin-100.woff2");
      (link_preload_font "assets/fonts/ibm-plex-serif-v19-latin-100italic.woff2");
      (link_preload_font "assets/fonts/ibm-plex-serif-v19-latin-200.woff2");
      (link_preload_font "assets/fonts/ibm-plex-serif-v19-latin-200italic.woff2");
      (link_preload_font "assets/fonts/ibm-plex-serif-v19-latin-300.woff2");
      (link_preload_font "assets/fonts/ibm-plex-serif-v19-latin-300italic.woff2");
      (link_preload_font "assets/fonts/ibm-plex-serif-v19-latin-regular.woff2");
      (link_preload_font "assets/fonts/ibm-plex-serif-v19-latin-italic.woff2");
      (link_preload_font "assets/fonts/ibm-plex-serif-v19-latin-400.woff2");
      (link_preload_font "assets/fonts/ibm-plex-serif-v19-latin-400italic.woff2");
      (link_preload_font "assets/fonts/ibm-plex-serif-v19-latin-500.woff2");
      (link_preload_font "assets/fonts/ibm-plex-serif-v19-latin-500italic.woff2");
      (link_preload_font "assets/fonts/ibm-plex-serif-v19-latin-600.woff2");
      (link_preload_font "assets/fonts/ibm-plex-serif-v19-latin-600italic.woff2");
      (link_preload_font "assets/fonts/ibm-plex-serif-v19-latin-700.woff2");
      (link_preload_font "assets/fonts/ibm-plex-serif-v19-latin-700italic.woff2");
      (style [txt ":root {--highlight-color: gray;}"]);
      (style [txt Funarch.Style.css]);
    ])

let div_styled sty contents = div ~a:[a_style sty] contents

let vspace = div ~a:[a_style "height: 2em;"] []

let blocks ~id:_id contents = div ~a:[a_style "display: flex; gap: 3em; flex-wrap: wrap;"] contents

let block contents = div ~a:[a_style "width: 20em;"] contents

let hdr =
  header ~a:[a_style "padding: 0em 2em 2em 2em;"]
    [
      div_styled "display: flex; justify-content: center;" [
        div_styled "flex: 1;
                    padding: 2em 0;
                    max-width: 120em;
                    border-bottom: 1px solid #ccc;" [
          b [txt "This page is a Work in Progress"];
          br ();
          txt "If you are interested in contributing to this overview \
               on functional software architecture, please head to";
          a ~a:[a_href "https://github.com/functional-architecture/functional-architecture.github.io"] [
            txt "this website’s GitHub repository."
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
        li [a ~a:[a_href "#publications"] [txt "Publications"]];
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
    ftr ~max_width:max_width ()]

let page_of_principle (pr : Funarch.Principles.principle) =
  let open Funarch.Principles in
  {
    Funarch.Page.filename = pr.filename;
    Funarch.Page.content =
      html
        main_head
        (body
           [(centered_with_footer
              ~max_width: "50em"
               (div
                  [div ~a:[a_role ["doc-subtitle"]]
                     [txt "Principle"];
                   (h1 [txt pr.title]);
                   match pr.long with
                   | Some desc -> desc
                   | None -> txt "TODO"]))])
  }

let principle_link pr =
  Funarch.Page.link (page_of_principle pr)

let pr_principle_short_block principle =
  let open Funarch.Principles in
  block [
    h3 [txt principle.title];
    p [txt principle.short];
    a ~a:[a_href (principle_link principle)] [
      txt "→ ";
      txt "More";
    ]
  ]

let pr_principles_blocks ps =
  blocks ~id:"principles" (List.map pr_principle_short_block ps)


let pr_pattern_short_block pattern =
  let open Funarch.Patterns in
  block [
    h3 [txt pattern.title];
    pattern.short]

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

let the_principles =
  div [
    h2 ~a:[a_id "principles"] [txt "Principles"];
    p [txt "We strive for the values described above. We do so by
            following this set of principles."];
    vspace;
    pr_principles_blocks Funarch.Principles.principles;
  ]

let the_patterns =
  div [
    h2 ~a:[a_id "patterns"] [txt "Patterns, Tools, and Techniques"];
    p [txt "We follow the principles described above by \
            employing some of the following techniques."];
    vspace;
    pr_patterns_blocks Funarch.Patterns.patterns;
  ]

let the_faqs =
  div ~a:[a_style "display: flex; flex-direction: column; gap: 1em; max-width: 50em;"] [
    h2 ~a:[a_id "faq"] [txt "Frequently Asked Questions"];
    vspace;
    div ~a:[a_style "display: flex; flex-direction: column; gap: 1em;"]
      (pr_faqs Funarch.Faqs.faqs);
  ]


let main_body = (body [
    hdr;
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
        the_principles;
        the_patterns;
        the_faqs;
      ]
    )])

let main_page =
  {
    Funarch.Page.filename = "index.html";
    Funarch.Page.content = html main_head main_body;
  }

let principles_pages =
  List.map page_of_principle Funarch.Principles.principles

let all_pages =
  List.concat
    [[main_page];
     principles_pages]

let out_dir = "out"

let () =
  Printf.printf "Functional Software Architecture\n";
  if not (Sys.file_exists out_dir)
      then Sys.mkdir out_dir 0o777;
  List.iter (Funarch.Page.render_page out_dir) all_pages
