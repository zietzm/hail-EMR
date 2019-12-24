import sys
import time

import boto3


cluster_id = sys.argv[1]

client = boto3.client('emr', region_name='us-east-1')

# Cluster state update
status = 'STARTING'
start_time = time.time()

# Wait until the cluster is created
while status != 'EMPTY':
    cluster_details = client.describe_cluster(ClusterId=cluster_id)
    status = cluster_details.get('Cluster').get('Status').get('State')
    print(f'Cluster status: {status}')
    if status == 'WAITING':
        total_time = time.time() - start_time
        print(f'Cluster created in {total_time / 60 :.2f} minutes')
        sys.exit(0)
    if status == 'TERMINATED_WITH_ERRORS':
        sys.exit("Cluster un-successfully created. Ending installation...")
    time.sleep(30)
