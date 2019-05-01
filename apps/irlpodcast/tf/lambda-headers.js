
'use strict';
// MUST be created in us-east-1
exports.handler = (event, context, callback) => {
    const request = event.Records[0].cf.request;
    const response = event.Records[0].cf.response; 
    const headers = response.headers; 
    response.headers['x-frame-options'] = [{"key":"X-Frame-Options","value":"DENY"}]; 
    response.headers['x-xss-protection'] = [{"key":"X-XSS-Protection","value":"1; mode=block"}]; 
    response.headers['x-content-type-options'] = [{"key":"X-Content-Type-Options","value":"nosniff"}]; 
    response.headers['content-security-policy'] = [{"key":"Content-Security-Policy","value":"font-src 'self' http://*.mozilla.net https://*.mozilla.net http://*.mozilla.org https://*.mozilla.org; img-src 'self' data: http://*.mozilla.net https://*.mozilla.net http://*.mozilla.org https://*.mozilla.org http://www.google-analytics.com https://www.google-analytics.com; style-src 'self' 'unsafe-inline' http://*.mozilla.org https://*.mozilla.org http://*.mozilla.net https://*.mozilla.net; script-src 'self' data: http://*.mozilla.org https://*.mozilla.org http://*.mozilla.net https://*.mozilla.net http://www.google-analytics.com https://www.google-analytics.com http://www.googletagmanager.com https://www.googletagmanager.com; default-src 'self' *.cdn.mozilla.net assets.mozilla.net; child-src 'self' embed.simplecast.com"}]; 
    response.headers['strict-transport-security'] = [{"key":"strict-transport-security","value":"max-age=31536000"}]; 
    
    callback(null, response);
};