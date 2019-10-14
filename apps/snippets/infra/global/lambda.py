def lambda_handler(event, context):
     response = event['Records'][0]['cf']['response']
 
     '''
     This function updates the response status to 200 and generates static
     body content to return to the viewer in the following scenario:
     1. The function is triggered in an origin response
     2. The response status from the origin server is an error status code (4xx or 5xx)
     '''
 
     if int(response['status']) >= 400 and int(response['status']) <= 599:
         response['status'] = 200
         response['statusDescription'] = 'OK'
         response['body'] = 'Foo'
     return response