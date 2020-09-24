'use strict';
// MUST be created in us-east-1
exports.handler = (event, context, callback) => {
   const request = event.Records[0].cf.request;
   const response = event.Records[0].cf.response; 
   const headers = response.headers; 
   response.headers['x-frame-options'] = [{"key":"X-Frame-Options","value":"DENY"}]; 
   response.headers['x-xss-protection'] = [{"key":"X-XSS-Protection","value":"1; mode=block"}]; 
   response.headers['x-content-type-options'] = [{"key":"X-Content-Type-Options","value":"nosniff"}]; 
   response.headers['content-security-policy'] = [{
       "key":"Content-Security-Policy",
       "value": "font-src 'self' https://*.mozilla.net https://*.mozilla.org; " +
                "img-src 'self' data: https://*.mozilla.net https://*.mozilla.org https://www.google-analytics.com; " +
                "style-src 'self' 'unsafe-inline' https://*.mozilla.org https://*.mozilla.net; " +
                "script-src 'self' 'unsafe-inline' data: https://*.mozilla.org https://*.mozilla.net https://www.google-analytics.com https://ssl.google-analytics.com https://www.googletagmanager.com; " +
                "connect-src: 'self' https://www.google-analytics.com; " +
                "default-src 'self' *.cdn.mozilla.net assets.mozilla.net www.youtube-nocookie.com"}];
   response.headers['strict-transport-security'] = [{"key":"strict-transport-security","value":"max-age=31536000"}]; 
    
   if(request.uri.startsWith('/feed/')) {
        response.headers['content-type'] = [{"key":"Content-Type","value":"application/rss+xml"}]; 
    }
    callback(null, response);
};

