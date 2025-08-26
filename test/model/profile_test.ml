open Lib.Model
open Test_util

let%expect_test "validating profile - 1 (invalid profile)" =
  let result =
    let+ profile = Yocaml.Data.(string "") |> Profile.validate in
    Profile.normalize profile
  in
  validation result;
  [%expect
    {|
    [INVALID] --- Oh dear, an error has occurred ---
    Validation error: `test`

    Fail with Invalid shape: { expected = `record`;given = `""`;}
    ---
    The backtrace is not available because the function is called (according to the [in_exception_handler] parameter) outside an exception handler. This makes the trace unspecified.
    |}]
;;

let%expect_test "validating profile - 2 (from mailbox)" =
  let result =
    let+ profile =
      Yocaml.Data.(string "Pierre Grim <grim@gmail.com>") |> Profile.validate
    in
    Profile.normalize profile
  in
  validation result;
  [%expect
    {|
    [VALID] {"display_name": "Pierre Grim", "last_name": null, "first_name":
             null, "avatar": null, "website": null, "email":
             {"address": "grim@gmail.com", "local": "grim", "domain":
              "gmail.com", "domain_fragments": ["gmail", "com"], "address_md5":
              "3d4f51b20864461509ebca757e75e887"},
            "x_account": null, "mastodon_account": null, "bsky_account": null,
            "more_accounts":
             {"elements": [], "length": 0, "has_elements": false}, "more_links":
             {"elements": [], "length": 0, "has_elements": false}, "more_emails":
             {"elements": [], "length": 0, "has_element": false}, "attributes":
             {"elements": [], "length": 0, "has_element": false},
            "has_last_name": false, "has_first_name": false, "has_avatar":
             false, "has_website": false, "has_email": true, "has_x_account":
             false, "has_mastodon_account": false, "has_bsky_account": false}
    |}]
;;

let%expect_test "validating profile - 3 (from string)" =
  let result =
    let+ profile = Yocaml.Data.(string "  Pierre Grim  ") |> Profile.validate in
    Profile.normalize profile
  in
  validation result;
  [%expect
    {|
    [VALID] {"display_name": "Pierre Grim", "last_name": null, "first_name":
             null, "avatar": null, "website": null, "email": null, "x_account":
             null, "mastodon_account": null, "bsky_account": null,
            "more_accounts":
             {"elements": [], "length": 0, "has_elements": false}, "more_links":
             {"elements": [], "length": 0, "has_elements": false}, "more_emails":
             {"elements": [], "length": 0, "has_element": false}, "attributes":
             {"elements": [], "length": 0, "has_element": false},
            "has_last_name": false, "has_first_name": false, "has_avatar":
             false, "has_website": false, "has_email": false, "has_x_account":
             false, "has_mastodon_account": false, "has_bsky_account": false}
    |}]
;;

let%expect_test "validating profile - 4 (from record with computed name)" =
  let result =
    let+ profile =
      Yocaml.Data.(
        record
          [ "first_name", string "Pierre"
          ; "last_name", string "Grim"
          ; ( "emails"
            , list [ pair string string ("principal", "grim@gmail.com") ] )
          ])
      |> Profile.validate
    in
    Profile.normalize profile
  in
  validation result;
  [%expect
    {|
    [VALID] {"display_name": "Pierre Grim", "last_name": "Grim", "first_name":
             "Pierre", "avatar": null, "website": null, "email":
             {"address": "grim@gmail.com", "local": "grim", "domain":
              "gmail.com", "domain_fragments": ["gmail", "com"], "address_md5":
              "3d4f51b20864461509ebca757e75e887"},
            "x_account": null, "mastodon_account": null, "bsky_account": null,
            "more_accounts":
             {"elements": [], "length": 0, "has_elements": false}, "more_links":
             {"elements": [], "length": 0, "has_elements": false}, "more_emails":
             {"elements":
              [{"key": "principal", "value":
                {"address": "grim@gmail.com", "local": "grim", "domain":
                 "gmail.com", "domain_fragments": ["gmail", "com"],
                "address_md5": "3d4f51b20864461509ebca757e75e887"}}],
             "length": 1, "has_element": true},
            "attributes": {"elements": [], "length": 0, "has_element": false},
            "has_last_name": true, "has_first_name": true, "has_avatar": false,
            "has_website": false, "has_email": true, "has_x_account": false,
            "has_mastodon_account": false, "has_bsky_account": false}
    |}]
;;

let%expect_test "validating profile - 5 (from record)" =
  let result =
    let+ profile =
      Yocaml.Data.(
        record
          [ "first_name", string "Pierre"
          ; "last_name", string "Grim"
          ; "display_name", string "grm"
          ; "x_account", string "grimfw"
          ; ( "emails"
            , list [ pair string string ("principal", "grim@gmail.com") ] )
          ])
      |> Profile.validate
    in
    Profile.normalize profile
  in
  validation result;
  [%expect
    {|
    [VALID] {"display_name": "grm", "last_name": "Grim", "first_name": "Pierre",
            "avatar": null, "website": null, "email":
             {"address": "grim@gmail.com", "local": "grim", "domain":
              "gmail.com", "domain_fragments": ["gmail", "com"], "address_md5":
              "3d4f51b20864461509ebca757e75e887"},
            "x_account": "grimfw", "mastodon_account": null, "bsky_account":
             null, "more_accounts":
             {"elements": [], "length": 0, "has_elements": false}, "more_links":
             {"elements": [], "length": 0, "has_elements": false}, "more_emails":
             {"elements":
              [{"key": "principal", "value":
                {"address": "grim@gmail.com", "local": "grim", "domain":
                 "gmail.com", "domain_fragments": ["gmail", "com"],
                "address_md5": "3d4f51b20864461509ebca757e75e887"}}],
             "length": 1, "has_element": true},
            "attributes": {"elements": [], "length": 0, "has_element": false},
            "has_last_name": true, "has_first_name": true, "has_avatar": false,
            "has_website": false, "has_email": true, "has_x_account": true,
            "has_mastodon_account": false, "has_bsky_account": false}
    |}]
;;

let%expect_test "validating profile - 5 (from record)" =
  let result =
    let+ profile =
      Yocaml.Data.(
        record
          [ "first_name", string "Pierre"
          ; "last_name", string "Grim"
          ; "display_name", string "grm"
          ; "x_account", string "grimfw"
          ; ( "emails"
            , list [ pair string string ("principal", "grim@gmail.com") ] )
          ])
      |> Profile.validate
    in
    Profile.normalize profile
  in
  validation result;
  [%expect
    {|
    [VALID] {"display_name": "grm", "last_name": "Grim", "first_name": "Pierre",
            "avatar": null, "website": null, "email":
             {"address": "grim@gmail.com", "local": "grim", "domain":
              "gmail.com", "domain_fragments": ["gmail", "com"], "address_md5":
              "3d4f51b20864461509ebca757e75e887"},
            "x_account": "grimfw", "mastodon_account": null, "bsky_account":
             null, "more_accounts":
             {"elements": [], "length": 0, "has_elements": false}, "more_links":
             {"elements": [], "length": 0, "has_elements": false}, "more_emails":
             {"elements":
              [{"key": "principal", "value":
                {"address": "grim@gmail.com", "local": "grim", "domain":
                 "gmail.com", "domain_fragments": ["gmail", "com"],
                "address_md5": "3d4f51b20864461509ebca757e75e887"}}],
             "length": 1, "has_element": true},
            "attributes": {"elements": [], "length": 0, "has_element": false},
            "has_last_name": true, "has_first_name": true, "has_avatar": false,
            "has_website": false, "has_email": true, "has_x_account": true,
            "has_mastodon_account": false, "has_bsky_account": false}
    |}]
;;
