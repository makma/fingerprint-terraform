backend F_fpcdn_io {
    .always_use_host_header = true;
    .between_bytes_timeout = 10s;
    .connect_timeout = 1s;
    .dynamic = true;
    .first_byte_timeout = 15s;
    .host = "fpcdn.io";
    .host_header = "fpcdn.io";
    .max_connections = 200;
    .port = "443";
    .share_key = "tFb9C4tyMavYBf2qzp01nD";
    .ssl = true;
    .ssl_cert_hostname = "fpcdn.io";
    .ssl_check_cert = always;
    .ssl_sni_hostname = "fpcdn.io";
    .probe = {
        .dummy = true;
        .initial = 5;
        .request = "HEAD / HTTP/1.1"  "Host: fpcdn.io" "Connection: close";
        .threshold = 1;
        .timeout = 2s;
        .window = 5;
        .expected_response = 200;
      }
}
backend F_api_fpjs_io {
    .always_use_host_header = true;
    .between_bytes_timeout = 10s;
    .connect_timeout = 1s;
    .dynamic = true;
    .first_byte_timeout = 15s;
    .host = "api.fpjs.io";
    .host_header = "api.fpjs.io";
    .max_connections = 200;
    .port = "443";
    .share_key = "tFb9C4tyMavYBf2qzp01nD";
    .ssl = true;
    .ssl_cert_hostname = "api.fpjs.io";
    .ssl_check_cert = always;
    .ssl_sni_hostname = "api.fpjs.io";
    .probe = {
        .dummy = true;
        .initial = 5;
        .request = "HEAD / HTTP/1.1"  "Host: api.fpjs.io" "Connection: close";
        .threshold = 1;
        .timeout = 2s;
        .window = 5;
        .expected_response = 200;
      }
}
backend F_eu_api_fpjs_io {
    .always_use_host_header = true;
    .between_bytes_timeout = 10s;
    .connect_timeout = 1s;
    .dynamic = true;
    .first_byte_timeout = 15s;
    .host = "eu.api.fpjs.io";
    .host_header = "eu.api.fpjs.io";
    .max_connections = 200;
    .port = "443";
    .share_key = "tFb9C4tyMavYBf2qzp01nD";
    .ssl = true;
    .ssl_cert_hostname = "eu.api.fpjs.io";
    .ssl_check_cert = always;
    .ssl_sni_hostname = "eu.api.fpjs.io";
    .probe = {
        .dummy = true;
        .initial = 5;
        .request = "HEAD / HTTP/1.1"  "Host: eu.api.fpjs.io" "Connection: close";
        .threshold = 1;
        .timeout = 2s;
        .window = 5;
        .expected_response = 200;
      }
}
backend F_ap_api_fpjs_io {
    .always_use_host_header = true;
    .between_bytes_timeout = 10s;
    .connect_timeout = 1s;
    .dynamic = true;
    .first_byte_timeout = 15s;
    .host = "ap.api.fpjs.io";
    .host_header = "ap.api.fpjs.io";
    .max_connections = 200;
    .port = "443";
    .share_key = "tFb9C4tyMavYBf2qzp01nD";
    .ssl = true;
    .ssl_cert_hostname = "ap.api.fpjs.io";
    .ssl_check_cert = always;
    .ssl_sni_hostname = "ap.api.fpjs.io";
    .probe = {
        .dummy = true;
        .initial = 5;
        .request = "HEAD / HTTP/1.1"  "Host: ap.api.fpjs.io" "Connection: close";
        .threshold = 1;
        .timeout = 2s;
        .window = 5;
        .expected_response = 200;
      }
}

sub proxy_agent_download_recv {
  declare local var.apikey STRING;
  set var.apikey = if (std.strlen(querystring.get(req.url, "apiKey")) > 0, querystring.get(req.url, "apiKey"), "");
  declare local var.version STRING;
  set var.version = if (std.strlen(querystring.get(req.url, "version")) > 0, querystring.get(req.url, "version"), "3");
  declare local var.loaderversion STRING;
  set var.loaderversion = if (std.strlen(querystring.get(req.url, "loaderVersion")) > 0, "/loader_v" + querystring.get(req.url, "loaderVersion") + ".js", "");

  set req.url = querystring.add(req.url, "ii", "fingerprint-pro-fastly-vcl/1.0.0/procdn");

  unset req.http.cookie;

  set req.url = "/v" + var.version + "/" + var.apikey + var.loaderversion + "?" + req.url.qs;
  set req.backend = F_fpcdn_io;
  return(lookup);
}

sub proxy_identification_request {
  set req.url = querystring.add(req.url, "ii", "fingerprint-pro-fastly-vcl/1.0.0/ingress");

  declare local var.cookie_iidt STRING;
  set var.cookie_iidt = req.http.cookie:_iidt;

  unset req.http.cookie;
  if (std.strlen(var.cookie_iidt) > 0) {
    set req.http.cookie:_iidt = var.cookie_iidt;
  }

  set req.http.FPJS-Proxy-Secret = table.lookup(fingerprint_config, "PROXY_SECRET");
  set req.http.FPJS-Proxy-Client-IP = req.http.fastly-client-ip;
  set req.http.FPJS-Proxy-Forwarded-Host = req.http.host;
  set req.url = "/?" + req.url.qs;
  set req.backend = F_api_fpjs_io;
  if (querystring.get(req.url, "region") == "eu") {
    set req.backend = F_eu_api_fpjs_io;
  }
  if(querystring.get(req.url, "region") == "ap") {
    set req.backend = F_ap_api_fpjs_io;
  }
  return(pass);
}

sub proxy_browser_cache_recv {
  if (req.url.path ~ "^/([\w|-]+)/([^/]+)(.*)?$") {
    if(re.group.1 == table.lookup(fingerprint_config, "INTEGRATION_PATH")) {
        declare local var.path STRING;
        set var.path = regsub(re.group.3, "^/+", "");
        set req.url = "/" var.path + "/?" + req.url.qs;

        unset req.http.cookie;
        set req.backend = F_api_fpjs_io;
        if (querystring.get(req.url, "region") == "eu") {
          set req.backend = F_eu_api_fpjs_io;
        }
        if(querystring.get(req.url, "region") == "ap") {
          set req.backend = F_ap_api_fpjs_io;
        }
        return(pass);
    }
  }
}

sub proxy_status_page_error {
    declare local var.style_nonce STRING;
    declare local var.integration_status_text STRING;

    declare local var.missing_env BOOL;
    set var.missing_env = false;

    declare local var.proxy_secret_missing BOOL;
    set var.proxy_secret_missing = false;

    declare local var.agent_path_missing BOOL;
    set var.agent_path_missing = false;

    declare local var.result_path_missing BOOL;
    set var.result_path_missing = false;

    declare local var.integration_path_missing BOOL;
    set var.integration_path_missing = false;

    if(std.strlen(table.lookup(fingerprint_config, "AGENT_SCRIPT_DOWNLOAD_PATH")) == 0) {
        set var.agent_path_missing = true;
    }
    if(std.strlen(table.lookup(fingerprint_config, "INTEGRATION_PATH")) == 0) {
        set var.integration_path_missing = true;
    }
    if(std.strlen(table.lookup(fingerprint_config, "GET_RESULT_PATH")) == 0) {
        set var.result_path_missing = true;
    }
    if(std.strlen(table.lookup(fingerprint_config, "PROXY_SECRET")) == 0) {
        set var.proxy_secret_missing = true;
    }

    if(var.proxy_secret_missing == true || var.agent_path_missing == true || var.result_path_missing == true) {
        set var.missing_env = true;
    }

    set var.integration_status_text = {"
        <p>
            <span>"}if(var.missing_env, "Your integration environment has problems", "Congratulations! Your integration deployed successfully"){"</span>
            <span>INTEGRATION_PATH: "} if(var.integration_path_missing, "❌", "✅") {"</span>
            <span>AGENT_SCRIPT_DOWNLOAD_PATH: "}if(var.agent_path_missing, "❌", "✅"){"</span>
            <span>GET_RESULT_PATH: "}if(var.result_path_missing, "❌", "✅"){"</span>
            <span>PROXY_SECRET: "}if(var.proxy_secret_missing, "❌", "✅"){"</span>
        </p>
    "};

    set var.style_nonce = randomstr(16, "1234567890abcdef");

    set req.http.Content-Security-Policy = {"default-src 'none'; img-src https://fingerprint.com; style-src 'nonce-"}var.style_nonce{"'"};

    declare local var.status_page_response STRING;
    set var.status_page_response = {"
    <!DOCTYPE html>
    <html>
        <head>
            <title>Fingerprint Pro Fastly VCL Integration</title>
            <link rel='icon' type='image/x-icon' href='https://fingerprint.com/img/favicon.ico'>
            <style nonce='"} var.style_nonce {"'>
              h1, span {
                display: block;
                padding-top: 1em;
                padding-bottom: 1em;
                text-align: center;
              }
            </style>
        </head>
        <body>
            <h1>Fingerprint Pro Fastly VCL Integration</h1>
            <span>
                Integration version: 1.0.0
            </span>
            <span>The following configuration values have been set: </span>
            "} var.integration_status_text {"
            <span>
                If you have any questions, please contact us at <a href='mailto:support@fingerprint.com'>support@fingerprint.com</a>.
            </span>
        </body>
    </html>
    "};

    set obj.status = 200;
    set obj.http.content-type = "text/html; charset=utf-8";
    synthetic var.status_page_response;

    return (deliver);
}

sub vcl_deliver {
#FASTLY deliver
  if (req.http.X-FPJS-REQUEST) {
      unset resp.http.Strict-Transport-Security;
  }
}

sub vcl_recv {
#FASTLY recv
    if(req.url.path ~ "^/([\w|-]+)") {
        if (re.group.1 == table.lookup(fingerprint_config, "INTEGRATION_PATH")) {
            set req.http.X-FPJS-REQUEST = "true";
        } else {
            return(pass);
        }
    } else {
        return(pass);
    }

    declare local var.target_path STRING;
    set var.target_path = "/" table.lookup(fingerprint_config, "INTEGRATION_PATH") "/" table.lookup(fingerprint_config, "AGENT_SCRIPT_DOWNLOAD_PATH");
    if (req.method == "GET" && req.url.path == var.target_path) {
      call proxy_agent_download_recv;
    }

    if (req.url.path ~ "^/([\w|-]+)/([^/]+)") {
        if (re.group.1 == table.lookup(fingerprint_config, "INTEGRATION_PATH") && re.group.2 == table.lookup(fingerprint_config, "GET_RESULT_PATH")) {
            if (req.method == "GET") {
                call proxy_browser_cache_recv;
            } else {
                call proxy_identification_request;
            }
        }
    }

    if (req.method == "GET" && req.url.path ~ "^/([\w|-]+)/status") {
        if (re.group.1 == table.lookup(fingerprint_config, "INTEGRATION_PATH")) {
            error 600;
        }
    }
}

sub vcl_error {
#FASTLY error
    if (obj.status == 600) {
        call proxy_status_page_error;
    }
}
