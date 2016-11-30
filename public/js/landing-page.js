window.isValidURL = (function() {// wrapped in self calling function to prevent global pollution

     //URL pattern based on rfc1738 and rfc3986
    var rg_pctEncoded = "%[0-9a-fA-F]{2}";
    var rg_protocol = "(http|https):\\/\\/";

    var rg_userinfo = "([a-zA-Z0-9$\\-_.+!*'(),;:&=]|" + rg_pctEncoded + ")+" + "@";

    var rg_decOctet = "(25[0-5]|2[0-4][0-9]|[0-1][0-9][0-9]|[1-9][0-9]|[0-9])"; // 0-255
    var rg_ipv4address = "(" + rg_decOctet + "(\\." + rg_decOctet + "){3}" + ")";
    var rg_hostname = "([a-zA-Z0-9\\-\\u00C0-\\u017F]+\\.)+([a-zA-Z]{2,})";
    var rg_port = "[0-9]+";

    var rg_hostport = "(" + rg_ipv4address + "|localhost|" + rg_hostname + ")(:" + rg_port + ")?";

    // chars sets
    // safe           = "$" | "-" | "_" | "." | "+"
    // extra          = "!" | "*" | "'" | "(" | ")" | ","
    // hsegment       = *[ alpha | digit | safe | extra | ";" | ":" | "@" | "&" | "=" | escape ]
    var rg_pchar = "a-zA-Z0-9$\\-_.+!*'(),;:@&=";
    var rg_segment = "([" + rg_pchar + "]|" + rg_pctEncoded + ")*";

    var rg_path = rg_segment + "(\\/" + rg_segment + ")*";
    var rg_query = "\\?" + "([" + rg_pchar + "/?]|" + rg_pctEncoded + ")*";
    var rg_fragment = "\\#" + "([" + rg_pchar + "/?]|" + rg_pctEncoded + ")*";

    var rgHttpUrl = new RegExp( 
        "^"
        + rg_protocol
        + "(" + rg_userinfo + ")?"
        + rg_hostport
        + "(\\/"
        + "(" + rg_path + ")?"
        + "(" + rg_query + ")?"
        + "(" + rg_fragment + ")?"
        + ")?"
        + "$"
    );

    // export public function
    return function (url) {
        if (rgHttpUrl.test(url)) {
            return true;
        } else {
            return false;
        }
    };
})();

(function() {
  var clickHandler = function() {
    var desiredUrl = $("#inputUrl").val();
    if (isValidURL(desiredUrl)) {
      console.log("Proxying to: [" + desiredUrl + "]");
      window.location = "http://corscamel.herokuapp.com/"+desiredUrl;
    } else {
      alert("You have entered an invalid URL. Please review and try again.");
    }
  }
  $("#submitProxy").click(clickHandler);
})();