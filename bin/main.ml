open Tyxml.Html
open Funarch.Web

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

(* let rec refify' xs k acc = *)
(*   match xs with *)
(*   | [] -> k (List.rev acc) *)
(*   | (x :: xs) -> *)
(*     with_ref (fun r -> refify' xs k (List.cons (x, r) acc)) *)

(* let refify (xs : 'a list) (k : ('a * ref) list -> 'b web) : 'b web = *)
(*   refify' xs k [] *)

let rec with_resources_acc ress get_data get_filename k acc =
  match ress with
  | [] -> k (List.rev acc)
  | (x :: xs) ->
    with_resource
      ~filename:(get_filename x)
      (get_data x)
      (fun ref ->
         (with_resources_acc
            xs
            get_data
            get_filename
            k
            (List.cons (x, ref) acc)))

let with_resources ress get_data get_filename k =
  with_resources_acc ress get_data get_filename k []

let head =
  with_resources
    Funarch.Style.fonts
    Funarch.Font.font_data
    Funarch.Font.font_output_file_name
    (fun fonts ->
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
               (List.map
                  (fun (_, r) ->
                     Funarch.Font.link_preload_font r)
                  fonts);
               [
                 (style [txt ":root {--highlight-color: gray;}"]);
                 (style [txt (Funarch.Style.css fonts)]);
               ]
             ])))

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
              txt "Mastodon: ";
              a ~a:[a_href "https://discuss.systems/@activegroupgmbh"] [txt "@activegroupgmbh@discuss.systems"]
            ];
            div [
              txt "Bluesky: ";
              a ~a:[a_href "https://bsky.app/profile/activegroupgmbh.bsky.social"] [txt "@activegroupgmbh.bsky.social"]
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
             | Draft desc -> desc
             | Published desc -> desc
             | Todo -> txt "TODO"]))])

let pr_principle_short_block (principle, page_ref) =
  let open Funarch.Principles in
  block [
    h3 [txt principle.title];
    p [txt principle.short];
    match principle.long with
    | Published _ -> (a ~a:[a_href (deref page_ref)] [
        txt "→ ";
        txt "More";
      ])
    | Draft _ -> txt "";
    | Todo -> txt "";
  ]

let pr_principles_blocks ps =
  blocks ~id:"principles" (List.map pr_principle_short_block ps)

let page_of_pattern (pattern : Funarch.Patterns.pattern) =
  let open Funarch.Patterns in
  let pato = pattern.long in
  let+ pat = match pato with
    | Published w -> w
    | Draft w -> w
    | Todo -> pure (txt "TODO") in
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
             pat
            ]))])

let pr_pattern_short_block (pattern, ref) =
  let open Funarch.Patterns in
  block [
    h3 [txt pattern.title];
    pattern.short;
    match pattern.long with
    | Published _ -> (a ~a:[a_href (deref ref)] [
        txt "→ ";
        txt "More";
      ])
    | Draft _ -> txt "";
    | Todo -> txt "";
  ]

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
                txt " refers to methods of construction and structure \
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

let funarch_2025 cfp_ref = (Funarch.Markdown.function_of_parameterized_markdown
                              "./events/funarch-2025/index.md"
                              ["{{call_for_participation}}"]
                              [(deref cfp_ref)])
let funarch_2025_cfp = (Funarch.Markdown.from_markdown_file "./events/funarch-2025/cfp/index.md")
let funarch_2024 = (Funarch.Markdown.from_markdown_file "./events/funarch-2024/index.md")
let funarch_2023 = (Funarch.Markdown.from_markdown_file "./events/funarch-2023/index.md")

let funarch_template title main =
  pure
    (body
       [hdr ~show_title:true `Events;
        (centered_with_footer
           ~max_width: "50em"
           (div
              [(h1 [txt title]);
               div ~a:[a_role ["doc-subtitle"]] [txt "Functional Software Architecture Workshop co-located with ICFP 2025"];
               vspace;
               main]))])

let events =
  let$ ref_2025 = 1 in
  let$ ref_2024 = 2 in
  let$ ref_2023 = 3 in
  (case
     [("funarch-2023",
       refer ref_2023 (funarch_template "FUNARCH 2023" funarch_2023));

      ("funarch-2024",
       refer ref_2024 (funarch_template "FUNARCH 2024" funarch_2024));

      ("funarch-2025",
       refer ref_2025
         (let^ cfp_ref = "cfp", funarch_template "FUNARCH 2025 - Call for Papers" funarch_2025_cfp in
          funarch_template "FUNARCH 2025" (funarch_2025 cfp_ref)))]

     (* default / *)
     (funarch_template
        "Events"
        (div
           [a ~a:[a_href (deref ref_2023)] [txt "FUNARCH 2023"];
            br ();
            a ~a:[a_href (deref ref_2024)] [txt "FUNARCH 2024"];
            br ();
            a ~a:[a_href (deref ref_2025)] [txt "FUNARCH 2025"];])))

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

let web_of_principle pr =
  pr.Funarch.Principles.route, (pure (page_of_principle pr))

let web_of_pattern pat =
  pat.Funarch.Patterns.route, (page_of_pattern pat)

let website =
  let open Funarch.Principles in
  let open Funarch.Patterns in
  map2
    html
    head
    (let^ functional_core_imperative_shell_ref = web_of_pattern functional_core_imperative_shell_pattern in
     let^ zipper_ref = web_of_pattern zipper_pattern in
     let^ continuations_ref = web_of_pattern continuations_pattern in
     let^ functional_programming_languages_ref = web_of_pattern functional_programming_languages_pattern in
     let^ static_types_ref = web_of_pattern static_types_pattern in
     let^ event_sourcing_ref = web_of_pattern event_sourcing_pattern in
     let^ bidirectional_data_transformation_ref = web_of_pattern bidirectional_data_transformation_pattern in
     let^ edsl_ref = web_of_pattern edsl_pattern in
     let^ composable_effects_ref = web_of_pattern composable_effects_pattern in
     let^ composable_error_handling_ref = web_of_pattern composable_error_handling_pattern in
     let^ composable_guis_ref = web_of_pattern composable_guis_pattern in
     let^ property_based_testing_ref = web_of_pattern property_based_testing_pattern in
     let^ formal_verification_ref = web_of_pattern formal_verification_pattern in
     let^ denotational_design_ref = web_of_pattern denotational_design_pattern in
     let^ parse_dont_validate_ref = web_of_pattern parse_dont_validate_pattern in
     let^ trees_that_grow_ref = web_of_pattern trees_that_grow_pattern in
     let^ data_types_a_la_carte_ref = web_of_pattern data_types_a_la_carte_pattern in
     let^ smart_constructor_ref = web_of_pattern smart_constructor_pattern in
     let^ correctness_by_construction_ref = web_of_pattern correctness_by_construction_pattern in

     let^ immutability_ref = web_of_principle immutability_principle in
     let^ purity_ref = web_of_principle purity_principle in
     let^ everything_as_a_value_ref = web_of_principle everything_as_a_value_principle in
     let^ composition_ref = web_of_principle composition_principle in
     let^ algebra_ref = web_of_principle algebra_principle in
     let^ abstraction_ref = web_of_principle abstraction_principle in
     let^ architecture_as_code_ref = web_of_principle architecture_as_code_principle in
     let^ decoupled_by_default_ref = web_of_principle decoupled_by_default_principle in
     let^ late_decision_making_ref = web_of_principle late_decision_making_principle in
     let^ modularization_ref = web_of_principle modularization_principle in
     let misu = (make_illegal_states_unrepresentable_principle
                   (deref static_types_ref)
                   (deref parse_dont_validate_ref)
                   (deref smart_constructor_ref)) in
     let^ misu_ref = web_of_principle misu in
     case
       [("publications", publications_page);
        ("events", events)]
       (pure (main_body
                [
                  (immutability_principle, immutability_ref);
                  (purity_principle, purity_ref);
                  (everything_as_a_value_principle, everything_as_a_value_ref);
                  (composition_principle, composition_ref);
                  (algebra_principle, algebra_ref);
                  (abstraction_principle, abstraction_ref);
                  (architecture_as_code_principle, architecture_as_code_ref);
                  (decoupled_by_default_principle, decoupled_by_default_ref);
                  (late_decision_making_principle, late_decision_making_ref);
                  (modularization_principle, modularization_ref);
                  (misu, misu_ref);
                ]
                [
                  (functional_core_imperative_shell_pattern, functional_core_imperative_shell_ref);
                  (zipper_pattern, zipper_ref);
                  (continuations_pattern, continuations_ref);
                  (functional_programming_languages_pattern, functional_programming_languages_ref);
                  (static_types_pattern, static_types_ref);
                  (event_sourcing_pattern, event_sourcing_ref);
                  (bidirectional_data_transformation_pattern, bidirectional_data_transformation_ref);
                  (edsl_pattern, edsl_ref);
                  (composable_effects_pattern, composable_effects_ref);
                  (composable_error_handling_pattern, composable_error_handling_ref);
                  (composable_guis_pattern, composable_guis_ref);
                  (property_based_testing_pattern, property_based_testing_ref);
                  (formal_verification_pattern, formal_verification_ref);
                  (denotational_design_pattern, denotational_design_ref);
                  (parse_dont_validate_pattern, parse_dont_validate_ref);
                  (trees_that_grow_pattern, trees_that_grow_ref);
                  (data_types_a_la_carte_pattern, data_types_a_la_carte_ref);
                  (smart_constructor_pattern, smart_constructor_ref);
                  (correctness_by_construction_pattern, correctness_by_construction_ref);
                ])))

let pr_html x = Format.asprintf "%a" (Tyxml.Html.pp ~indent:false ()) x

let out_dir = "out"

let () =
  Printf.printf "Functional Software Architecture\n";
  if not (Sys.file_exists out_dir)
      then Sys.mkdir out_dir 0o777;
  render ~directory:out_dir (map pr_html website);
