# Return empty JSON object when Origin doesn't have the file.

def lambda_handler(event, context):
    request = event['Records'][0]['cf']['request']
    response = event['Records'][0]['cf']['response']

    url = request['uri']
    if not url.startswith('/7/'):
        return response

    if int(response['status']) == 404:
        response['status'] = 200
        response['statusDescription'] = 'OK'
        response['body'] = '{}'
    return response
