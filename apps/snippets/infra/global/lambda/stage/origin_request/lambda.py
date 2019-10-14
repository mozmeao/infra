import os


def redirect(url):
    response = {
        'status': '302',
        'statusDescription': 'Found',
        'headers': {
            'location': [{
                'key': 'Location',
                'value': url
            }],
            'cache-control': [{
                'key': 'Cache-Control',
                'value': 'max-age=60'  # One minute, to be increased
            }],
        }
    }
    return response


def lambda_handler(event, context):
    # Must end with '/'
    CDN_ROOT = os.getenv(
        'CDN_ROOT',
        'https://snippets.cdn.mozilla.net/us-west/bundles-pregen/'
    )
    CHANNELS = [
        'release',
        'esr',
        'beta',
        'aurora',
        'nightly',
    ]

    request = event['Records'][0]['cf']['request']
    url = request['uri']

    if not url.startswith('/7/'):
        return request

    url = url[3:]
    product, channel, locale, distribution = url.split('/', 4)

    channel = channel.lower()
    channel = next((item for item in CHANNELS if channel.startswith(item)), None) or 'release'
    locale = locale.lower()
    distribution = distribution.lower()

    new_url = '/'.join([product, channel, locale, distribution])
    return redirect(f'{CDN_ROOT}{new_url}')


if __name__ == '__main__':
    context = {
        'Records': [
            {
                'cf': {
                    'request': {
                        'uri': '/7/Firefox/beta-dns/en-US/default.json'
                    }
                }
            }
        ]
    }
    print(lambda_handler(context, None))
