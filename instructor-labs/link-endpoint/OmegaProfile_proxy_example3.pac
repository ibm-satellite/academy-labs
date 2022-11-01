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
	
        if (/^127\.0\.0\.1$/.test(host) || /^::1$/.test(host) || /^localhost$/.test(host) || /^iam\.cloud\.ibm\.com$/.test(host) || /^login\.ibm\.com$/.test(host) || /^login\.w3\.ibm\.com$/.test(host) || /^www\.ibm\.com$/.test(host) || /^w3id-ns\.sso\.ibm\.com$/.test(host) || /^ibm\.biz$/.test(host) || /^iam\.bluemix\.net$/.test(host) || /^identity-1\.us-south\.iam\.cloud\.ibm\.com$/.test(host) || /^identity-2\.us-south\.iam\.cloud\.ibm\.com$/.test(host) || /^identity-3\.us-south\.iam\.cloud\.ibm\.com$/.test(host)) return "DIRECT";
        if (/^xxx-xxx-ce00\.us-south\.satellite\.appdomain\.cloud$/.test(host)) return "HTTPS c-04.private.us-south.link.satellite.cloud.ibm.com:xxxx";
        if (/^console-openshift-console\.xxx-xxx-0000\.us-south\.containers\.appdomain\.cloud$/.test(host)) return "HTTPS c-04.private.us-south.link.satellite.cloud.ibm.com:yyyy";
        if (/^ta-apps\.xxx-xxx-0000\.us-south\.containers\.appdomain\.cloud$/.test(host)) return "HTTPS c-04.private.us-south.link.satellite.cloud.ibm.com:zzzzz";
     
        return "DIRECT";
    }
});
