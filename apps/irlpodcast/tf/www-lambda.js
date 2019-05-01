'use strict';
// https://medium.com/@chrispointon/redirecting-non-www-to-www-website-in-aws-cloudfront-658d97764b42
exports.handler = (event, context, callback) => {
    // Extract the request from the CloudFront event that is sent to Lambda@Edge 
    var request = event.Records[0].cf.request;

    var params = '';
    if(('querystring' in request) && (request.querystring.length>0)) {
        params = '?'+request.querystring;
    }

    var miduri = request.uri.replace(/(\/[\w\-_]+)$/, '$1/');
    var newuri = "https://irlpodcast.org" + miduri + params;
    
    const response = {
        status: '301',
        statusDescription: 'Permanently moved',
            headers: {
            location: [{
                key: 'Location',
                value: newuri
                }]
            }
        };
    return callback(null, response);
};