/**
 * FingerprintJS Pro Cloudflare Worker v1.5.0 - Copyright (c) FingerprintJS, Inc, 2023 (https://fingerprint.com)
 * Licensed under the MIT (http://www.opensource.org/licenses/mit-license.php) license.
 */

const Defaults = {
    AGENT_SCRIPT_DOWNLOAD_PATH: 'agent',
    GET_RESULT_PATH: 'getResult',
    PROXY_SECRET: null,
};
function getVarOrDefault(variable, defaults) {
    return function (env) {
        return (env[variable] || defaults[variable]);
    };
}
function isVarSet(variable) {
    return function (env) {
        return env[variable] != null;
    };
}
const agentScriptDownloadPathVarName = 'AGENT_SCRIPT_DOWNLOAD_PATH';
const getAgentPathVar = getVarOrDefault(agentScriptDownloadPathVarName, Defaults);
const isScriptDownloadPathSet = isVarSet(agentScriptDownloadPathVarName);
function getScriptDownloadPath(env) {
    const agentPathVar = getAgentPathVar(env);
    return `/${agentPathVar}`;
}
const getResultPathVarName = 'GET_RESULT_PATH';
const getGetResultPathVar = getVarOrDefault(getResultPathVarName, Defaults);
const isGetResultPathSet = isVarSet(getResultPathVarName);
function getGetResultPath(env) {
    const getResultPathVar = getGetResultPathVar(env);
    return `/${getResultPathVar}(/.*)?`;
}
const proxySecretVarName = 'PROXY_SECRET';
const getProxySecretVar = getVarOrDefault(proxySecretVarName, Defaults);
const isProxySecretSet = isVarSet(proxySecretVarName);
function getProxySecret(env) {
    return getProxySecretVar(env);
}
function getStatusPagePath() {
    return `/status`;
}

function setDirective(directives, directive, maxMaxAge) {
    const directiveIndex = directives.findIndex((directivePair) => directivePair.split('=')[0].trim().toLowerCase() === directive);
    if (directiveIndex === -1) {
        directives.push(`${directive}=${maxMaxAge}`);
    }
    else {
        const oldValue = Number(directives[directiveIndex].split('=')[1]);
        const newValue = Math.min(maxMaxAge, oldValue);
        directives[directiveIndex] = `${directive}=${newValue}`;
    }
}
function getCacheControlHeaderWithMaxAgeIfLower(cacheControlHeaderValue, maxMaxAge, maxSMaxAge) {
    const cacheControlDirectives = cacheControlHeaderValue.split(', ');
    setDirective(cacheControlDirectives, 'max-age', maxMaxAge);
    setDirective(cacheControlDirectives, 's-maxage', maxSMaxAge);
    return cacheControlDirectives.join(', ');
}

function errorToString(error) {
    try {
        return typeof error === 'string' ? error : error instanceof Error ? error.message : String(error);
    }
    catch (e) {
        return 'unknown';
    }
}
function generateRandomString(length) {
    let result = '';
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    for (let i = 0; i < length; i++) {
        result += characters.charAt(Math.floor(Math.random() * characters.length));
    }
    return result;
}
function generateRequestUniqueId() {
    return generateRandomString(6);
}
function generateRequestId() {
    const uniqueId = generateRequestUniqueId();
    const now = new Date().getTime();
    return `${now}.${uniqueId}`;
}
function createErrorResponseForIngress(request, error) {
    const reason = errorToString(error);
    const errorBody = {
        code: 'IntegrationFailed',
        message: `An error occurred with Cloudflare worker. Reason: ${reason}`,
    };
    const responseBody = {
        v: '2',
        error: errorBody,
        requestId: generateRequestId(),
        products: {},
    };
    const requestOrigin = request.headers.get('origin') || '';
    const responseHeaders = {
        'Access-Control-Allow-Origin': requestOrigin,
        'Access-Control-Allow-Credentials': 'true',
        'content-type': 'application/json',
    };
    return new Response(JSON.stringify(responseBody), { status: 500, headers: responseHeaders });
}
function createFallbackErrorResponse(error) {
    const responseBody = { error: errorToString(error) };
    return new Response(JSON.stringify(responseBody), { status: 500, headers: { 'content-type': 'application/json' } });
}

async function fetchCacheable(request, ttl) {
    return fetch(request, { cf: { cacheTtl: ttl } });
}

const INT_VERSION = '1.5.0';
const PARAM_NAME = 'ii';
function getTrafficMonitoringValue(type) {
    return `fingerprintjs-pro-cloudflare/${INT_VERSION}/${type}`;
}
function addTrafficMonitoringSearchParamsForProCDN(url) {
    url.searchParams.append(PARAM_NAME, getTrafficMonitoringValue('procdn'));
}
function addTrafficMonitoringSearchParamsForVisitorIdRequest(url) {
    url.searchParams.append(PARAM_NAME, getTrafficMonitoringValue('ingress'));
}

function returnHttpResponse(oldResponse) {
    oldResponse.headers.delete('Strict-Transport-Security');
    return oldResponse;
}

function addProxyIntegrationHeaders(headers, url, env) {
    const proxySecret = getProxySecret(env);
    if (proxySecret) {
        headers.set('FPJS-Proxy-Secret', proxySecret);
        headers.set('FPJS-Proxy-Client-IP', headers.get('CF-Connecting-IP') || '');
        headers.set('FPJS-Proxy-Forwarded-Host', new URL(url).hostname);
    }
}

/*!
 * cookie
 * Copyright(c) 2012-2014 Roman Shtylman
 * Copyright(c) 2015 Douglas Christopher Wilson
 * MIT Licensed
 */

/**
 * Module exports.
 * @public
 */

var parse_1 = parse;

/**
 * Parse a cookie header.
 *
 * Parse the given cookie header string into an object
 * The object has the various cookies as keys(names) => values
 *
 * @param {string} str
 * @param {object} [options]
 * @return {object}
 * @public
 */

function parse(str, options) {
  if (typeof str !== 'string') {
    throw new TypeError('argument str must be a string');
  }

  var obj = {};
  var opt = options || {};
  var dec = opt.decode || decode;

  var index = 0;
  while (index < str.length) {
    var eqIdx = str.indexOf('=', index);

    // no more cookie pairs
    if (eqIdx === -1) {
      break
    }

    var endIdx = str.indexOf(';', index);

    if (endIdx === -1) {
      endIdx = str.length;
    } else if (endIdx < eqIdx) {
      // backtrack on prior semicolon
      index = str.lastIndexOf(';', eqIdx - 1) + 1;
      continue
    }

    var key = str.slice(index, eqIdx).trim();

    // only assign once
    if (undefined === obj[key]) {
      var val = str.slice(eqIdx + 1, endIdx).trim();

      // quoted values
      if (val.charCodeAt(0) === 0x22) {
        val = val.slice(1, -1);
      }

      obj[key] = tryDecode(val, dec);
    }

    index = endIdx + 1;
  }

  return obj;
}

/**
 * URL-decode string value. Optimized to skip native call when no %.
 *
 * @param {string} str
 * @returns {string}
 */

function decode (str) {
  return str.indexOf('%') !== -1
    ? decodeURIComponent(str)
    : str
}

/**
 * Try decoding a string using a decoding function.
 *
 * @param {string} str
 * @param {function} decode
 * @private
 */

function tryDecode(str, decode) {
  try {
    return decode(str);
  } catch (e) {
    return str;
  }
}

function filterCookies(headers, filterFunc) {
    const newHeaders = new Headers(headers);
    const cookie = parse_1(headers.get('cookie') || '');
    const filteredCookieList = [];
    for (const cookieName in cookie) {
        if (filterFunc(cookieName)) {
            filteredCookieList.push(`${cookieName}=${cookie[cookieName]}`);
        }
    }
    newHeaders.delete('cookie');
    if (filteredCookieList.length > 0) {
        newHeaders.set('cookie', filteredCookieList.join('; '));
    }
    return newHeaders;
}

function removeTrailingSlashesAndMultiSlashes(str) {
    return str.replace(/\/+$/, '').replace(/(?<=\/)\/+/, '');
}
function addPathnameMatchBeforeRoute(route) {
    return `[\\/[A-Za-z0-9:._-]*${route}`;
}
function addEndingTrailingSlashToRoute(route) {
    return `${route}\\/*`;
}
function createRoute(route) {
    let routeRegExp = route;
    // routeRegExp = addTrailingWildcard(routeRegExp) // Can be uncommented if wildcard (*) is needed
    routeRegExp = removeTrailingSlashesAndMultiSlashes(routeRegExp);
    routeRegExp = addPathnameMatchBeforeRoute(routeRegExp);
    routeRegExp = addEndingTrailingSlashToRoute(routeRegExp);
    // routeRegExp = replaceDot(routeRegExp) // Can be uncommented if dot (.) is needed
    return RegExp(`^${routeRegExp}$`);
}

const DEFAULT_AGENT_VERSION = '3';
function getAgentScriptEndpoint(searchParams) {
    const apiKey = searchParams.get('apiKey');
    const apiVersion = searchParams.get('version') || DEFAULT_AGENT_VERSION;
    const base = `https://fpcdn.io/v${apiVersion}/${apiKey}`;
    const loaderVersion = searchParams.get('loaderVersion');
    const lv = loaderVersion ? `/loader_v${loaderVersion}.js` : '';
    return `${base}${lv}`;
}
function getVisitorIdEndpoint(searchParams, pathSuffix = undefined) {
    const region = searchParams.get('region') || 'us';
    let prefix = '';
    switch (region) {
        case 'eu':
            prefix = 'eu.';
            break;
        case 'ap':
            prefix = 'ap.';
            break;
        default:
            prefix = '';
            break;
    }
    let suffix = pathSuffix ?? '';
    if (suffix.length > 0 && !suffix.startsWith('/')) {
        suffix = '/' + suffix;
    }
    return `https://${prefix}api.fpjs.io${suffix}`;
}

function createResponseWithMaxAge(oldResponse, maxMaxAge, maxSMaxAge) {
    const response = new Response(oldResponse.body, oldResponse);
    const oldCacheControlHeader = oldResponse.headers.get('cache-control');
    if (!oldCacheControlHeader) {
        return response;
    }
    const cacheControlHeader = getCacheControlHeaderWithMaxAgeIfLower(oldCacheControlHeader, maxMaxAge, maxSMaxAge);
    response.headers.set('cache-control', cacheControlHeader);
    return response;
}

function copySearchParams$1(oldURL, newURL) {
    newURL.search = new URLSearchParams(oldURL.search).toString();
}
function makeDownloadScriptRequest(request) {
    const oldURL = new URL(request.url);
    const agentScriptEndpoint = getAgentScriptEndpoint(oldURL.searchParams);
    const newURL = new URL(agentScriptEndpoint);
    copySearchParams$1(oldURL, newURL);
    addTrafficMonitoringSearchParamsForProCDN(newURL);
    const headers = new Headers(request.headers);
    headers.delete('Cookie');
    console.log(`Downloading script from cdnEndpoint ${newURL.toString()}...`);
    const newRequest = new Request(newURL.toString(), new Request(request, { headers }));
    const workerCacheTtl = 60;
    const maxMaxAge = 60 * 60;
    const maxSMaxAge = 60;
    return fetchCacheable(newRequest, workerCacheTtl).then((res) => createResponseWithMaxAge(res, maxMaxAge, maxSMaxAge));
}
async function handleDownloadScript(request) {
    try {
        return await makeDownloadScriptRequest(request);
    }
    catch (e) {
        return createFallbackErrorResponse(e);
    }
}

function copySearchParams(oldURL, newURL) {
    newURL.search = new URLSearchParams(oldURL.search).toString();
}
function createRequestURL(receivedRequestURL, routeMatches) {
    const routeSuffix = routeMatches ? routeMatches[1] : undefined;
    const oldURL = new URL(receivedRequestURL);
    const endpoint = getVisitorIdEndpoint(oldURL.searchParams, routeSuffix);
    const newURL = new URL(endpoint);
    copySearchParams(oldURL, newURL);
    return newURL;
}
async function makeIngressRequest(receivedRequest, env, routeMatches) {
    const requestURL = createRequestURL(receivedRequest.url, routeMatches);
    addTrafficMonitoringSearchParamsForVisitorIdRequest(requestURL);
    let headers = new Headers(receivedRequest.headers);
    headers = filterCookies(headers, (key) => key === '_iidt');
    addProxyIntegrationHeaders(headers, receivedRequest.url, env);
    const body = await (receivedRequest.headers.get('Content-Type') ? receivedRequest.blob() : Promise.resolve(null));
    console.log(`sending ingress request to ${requestURL}...`);
    const request = new Request(requestURL, new Request(receivedRequest, { headers, body }));
    return fetch(request).then((oldResponse) => new Response(oldResponse.body, oldResponse));
}
function makeCacheEndpointRequest(receivedRequest, routeMatches) {
    const requestURL = createRequestURL(receivedRequest.url, routeMatches);
    const headers = new Headers(receivedRequest.headers);
    headers.delete('Cookie');
    console.log(`sending cache request to ${requestURL}...`);
    const request = new Request(requestURL, new Request(receivedRequest, { headers }));
    return fetch(request).then((oldResponse) => new Response(oldResponse.body, oldResponse));
}
async function handleIngressAPI(request, env, routeMatches) {
    if (request.method === 'GET') {
        try {
            return await makeCacheEndpointRequest(request, routeMatches);
        }
        catch (e) {
            return createFallbackErrorResponse(e);
        }
    }
    try {
        return await makeIngressRequest(request, env, routeMatches);
    }
    catch (e) {
        return createErrorResponseForIngress(request, e);
    }
}

function generateNonce() {
    let result = '';
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    const indices = crypto.getRandomValues(new Uint8Array(24));
    for (const index of indices) {
        result += characters[index % characters.length];
    }
    return btoa(result);
}
function buildHeaders(styleNonce) {
    const headers = new Headers();
    headers.append('Content-Type', 'text/html');
    headers.append('Content-Security-Policy', `default-src 'none'; img-src https://fingerprint.com; style-src 'nonce-${styleNonce}'`);
    return headers;
}
function createWorkerVersionElement() {
    return `
  <span>
  ℹ️ Worker version: 1.5.0
  </span>
  `;
}
function createContactInformationElement() {
    return `
  <span>
  ❓Please reach out our support via <a href='mailto:support@fingerprint.com'>support@fingerprint.com</a> if you have any issues
  </span>
  `;
}
function createEnvVarsInformationElement(env) {
    const isScriptDownloadPathAvailable = isScriptDownloadPathSet(env);
    const isGetResultPathAvailable = isGetResultPathSet(env);
    const isProxySecretAvailable = isProxySecretSet(env);
    const isAllVarsAvailable = isScriptDownloadPathAvailable && isGetResultPathAvailable && isProxySecretAvailable;
    let result = '';
    if (!isAllVarsAvailable) {
        result += `
    <span>
    The following environment variables are not defined. Please reach out our support team.
    </span>
    `;
        if (!isScriptDownloadPathAvailable) {
            result += `
      <span>
      ⚠️ <strong>${agentScriptDownloadPathVarName} </strong> is not set
      </span>
      `;
        }
        if (!isGetResultPathAvailable) {
            result += `
      <span>
      ⚠️ <strong>${getResultPathVarName} </strong> is not set
      </span>
      `;
        }
        if (!isProxySecretAvailable) {
            result += `
      <span>
      ⚠️ <strong>${proxySecretVarName} </strong> is not set
      </span>
      `;
        }
    }
    else {
        result += `
    <span>
     ✅ All environment variables are set
    </span>
    `;
    }
    return result;
}
function buildBody(env, styleNonce) {
    let body = `
  <html lang='en-US'>
  <head>
    <meta charset='utf-8'/>
    <title>Fingerprint Pro Cloudflare Worker</title>
    <link rel='icon' type='image/x-icon' href='https://fingerprint.com/img/favicon.ico'>
    <style nonce='${styleNonce}'>
      h1, span {
        display: block;
        padding-top: 1em;
        padding-bottom: 1em;
        text-align: center;
      }
    </style>
  </head>
  <body>
    <h1>Fingerprint Pro Cloudflare Integration</h1>
  `;
    body += `<span>🎉 Your Cloudflare worker is deployed</span>`;
    body += createWorkerVersionElement();
    body += createEnvVarsInformationElement(env);
    body += createContactInformationElement();
    body += `  
  </body>
  </html>
  `;
    return body;
}
function handleStatusPage(request, env) {
    if (request.method !== 'GET') {
        return new Response(null, { status: 405 });
    }
    const styleNonce = generateNonce();
    const headers = buildHeaders(styleNonce);
    const body = buildBody(env, styleNonce);
    return new Response(body, {
        status: 200,
        statusText: 'OK',
        headers,
    });
}

function createRoutes(env) {
    const routes = [];
    const downloadScriptRoute = {
        pathPattern: createRoute(getScriptDownloadPath(env)),
        handler: handleDownloadScript,
    };
    const ingressAPIRoute = {
        pathPattern: createRoute(getGetResultPath(env)),
        handler: handleIngressAPI,
    };
    const statusRoute = {
        pathPattern: createRoute(getStatusPagePath()),
        handler: (request, env) => handleStatusPage(request, env),
    };
    routes.push(downloadScriptRoute);
    routes.push(ingressAPIRoute);
    routes.push(statusRoute);
    return routes;
}
function handleNoMatch(urlPathname) {
    const responseHeaders = new Headers({
        'content-type': 'application/json',
    });
    return new Response(JSON.stringify({ error: `unmatched path ${urlPathname}` }), {
        status: 404,
        headers: responseHeaders,
    });
}
function handleRequestWithRoutes(request, env, routes) {
    const url = new URL(request.url);
    for (const route of routes) {
        const matches = url.pathname.match(route.pathPattern);
        if (matches) {
            return route.handler(request, env, matches);
        }
    }
    return handleNoMatch(url.pathname);
}
async function handleRequest(request, env) {
    const routes = createRoutes(env);
    return handleRequestWithRoutes(request, env, routes);
}

var index = {
    async fetch(request, env) {
        return handleRequest(request, env).then(returnHttpResponse);
    },
};

export { index as default };
