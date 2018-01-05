import click
import boto3

"""
Delete snapshots for given EBS volume ID(s) that are older than a given number of days
"""

def process_volume_snapshots(client, volid, days_to_keep, yes):
    snapshots = client.describe_snapshots(
        Filters=[{'Name': "volume-id",'Values': [volid]},])

    filtered_snapshots = snapshots[u'Snapshots']
    sorted_filtered_snapshots = sorted(filtered_snapshots, key=lambda k: k[u'StartTime'], reverse=True)
    if len(sorted_filtered_snapshots) > 7:
        snapshots_to_delete = sorted_filtered_snapshots[days_to_keep:]
        for snapshot in snapshots_to_delete:
            dryrun_status = '[No change]' if not yes else '[Deleting]'
            print(dryrun_status, snapshot[u'VolumeId'], snapshot[u'SnapshotId'], snapshot[u'StartTime'])
            if yes:
                client.delete_snapshot(SnapshotId=snapshot[u'SnapshotId'])
    else:
        print("<= {} snapshots for {}, nothing to do.".format(days_to_keep, volid))

@click.command()
@click.option('--region', '-r', help='Target AWS region')
@click.option('--volume', '-v', multiple=True, help='EBS volume ID, specify multiple with -v foo -v bar ...')
@click.option('--days-to-keep', '-d', default=7)
@click.option('--yes', is_flag=True, help='Apply changes')
def doit(region, volume, days_to_keep, yes):
    client = boto3.client('ec2', region_name=region)
    if not yes:
        print("Dry run mode")
    for v in volume:
        print("Processing",v)
        process_volume_snapshots(client, v, days_to_keep, yes)

if __name__ == '__main__':
    doit()