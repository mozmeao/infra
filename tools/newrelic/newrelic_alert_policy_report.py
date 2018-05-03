import requests
from munch import munchify, unmunchify
from decouple import config
import yaml

NEW_RELIC_API_KEY = config('NEW_RELIC_API_KEY')


def nr(url, params=None):
    headers = {'X-Api-Key': NEW_RELIC_API_KEY}
    response = requests.get(url, headers=headers, params=params)
    return munchify(response.json())


def get_conditions(policy_id, entity_ids):
    conditions_response = nr(
        'https://api.newrelic.com/v2/alerts_conditions.json',
        params={
            'policy_id': policy_id})
    for condition in conditions_response.conditions:
        condition.entity_names = [
            entity_ids[int(entity)] for entity in condition.entities]
    return conditions_response


def get_entities():
    all_apps = nr('https://api.newrelic.com/v2/applications.json')
    pairs = [(app.id, app.name) for app in all_apps.applications]
    return dict(pairs)


def get_policies(entity_ids):
    all_policies = nr('https://api.newrelic.com/v2/alerts_policies.json')
    for policy in all_policies.policies:
        policy.conditions = get_conditions(policy.id, entity_ids)
    return [{policy.name: policy} for policy in all_policies.policies]


entity_ids = get_entities()
print(yaml.dump(unmunchify(get_policies(entity_ids))))
