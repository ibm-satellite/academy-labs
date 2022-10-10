var FindProxyForURL = function(init, profiles) {
    return function(url, host) {
        "use strict";
        var result = init, scheme = url.substr(0, url.indexOf(":"));
        do {
            result = profiles[result];
            if (typeof result === "function") result = result(url, host, scheme);
        } while (typeof result !== "string" || result.charCodeAt(0) === 43);
        return result;
    };
}("+proxy", {
    "+proxy": function(url, host, scheme) {
        "use strict";
	
        if (/^127\.0\.0\.1$/.test(host) || /^::1$/.test(host) || /^localhost$/.test(host) || /^i10c37a0d32a841019b1e-6b64a6ccc9c596bf59a86625d8fa2202-ce00\.us-east\.satellite\.appdomain\.cloud$/.test(host) || /^iam\.cloud\.ibm\.com$/.test(host) || /^login\.ibm\.com$/.test(host) || /^login\.w3\.ibm\.com$/.test(host) || /^www\.ibm\.com$/.test(host) || /^w3id-ns\.sso\.ibm\.com$/.test(host) || /^ibm\.biz$/.test(host) || /^iam\.bluemix\.net$/.test(host) || /^identity-1\.us-south\.iam\.cloud\.ibm\.com$/.test(host) || /^identity-2\.us-south\.iam\.cloud\.ibm\.com$/.test(host) || /^identity-3\.us-south\.iam\.cloud\.ibm\.com$/.test(host)) return "DIRECT";
        return "HTTPS c-04.private.us-east.link.satellite.cloud.ibm.com:33845";
    }
});