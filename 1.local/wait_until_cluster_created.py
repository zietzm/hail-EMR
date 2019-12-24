import sys
import time

import boto3


cluster_id = sys.argv[1]
print(f'\nClusterId: {cluster_id}\n')

# Gives EMR cluster information
client_EMR = boto3.client('emr', region_name='us-east-1')

# Cluster state update
status_EMR = 'STARTING'
tic = time.time()
# Wait until the cluster is created
while status_EMR != 'EMPTY':
    print('Creating EMR...')
    details_EMR = client_EMR.describe_cluster(ClusterId=cluster_id)
    status_EMR = details_EMR.get('Cluster').get('Status').get('State')
    print(f'Cluster status: {status_EMR}')
    time.sleep(30)
    if status_EMR == 'WAITING':
        toc = time.time() - tic
        print('Cluster successfully created! Starting HAIL installation.')
        print(f"Total time to provision your cluster: {toc / 60 :.2f} minutes")
    if status_EMR == 'TERMINATED_WITH_ERRORS':
        sys.exit("Cluster un-successfully created. Ending installation...")
