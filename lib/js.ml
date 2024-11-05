type js_inline_module = {
  data : string;
}

let make_js_inline_module s =
  { data = s }

let js_script_tag js =
  let open Tyxml.Html in
  (script ~a:[a_script_type `Module] (txt js.data))
