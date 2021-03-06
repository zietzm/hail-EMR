#!/bin/bash

# Set variables using manual configurations
. ./config/manual_configs.sh

# Configure the AWS key name
KeyName=${AWS_KEY##*/}
KeyName="${KeyName%.pem}"
cat config/ec2_attributes.json |
  jq --arg KeyName $KeyName '{KeyName: $KeyName} + .' > \
  config/ec2_attributes.json

# Install AWS Python library
pip install boto3

mkdir -p logs

# Create EMR cluster using spot instances
aws emr create-cluster \
--applications Name=Hadoop Name=Spark \
--name $CLUSTER_NAME \
--service-role EMR_DefaultRole \
--auto-scaling-role EMR_AutoScaling_DefaultRole \
--release-label emr-5.28.0 \
--ec2-attributes file://config/ec2_attributes.json \
--ebs-root-volume-size 32 \
--instance-groups file://config/instance_groups.json \
--configurations '[{"Classification":"spark","Properties":{"maximizeResourceAllocation":"true"}},{"Classification":"yarn-site","Properties":{"yarn.nodemanager.vmem-check-enabled":"false"},"Configurations":[]}]' \
--scale-down-behavior TERMINATE_AT_TASK_COMPLETION \
--region us-east-1 \
--enable-debugging \
--log-uri $LOG_URI \
> logs/aws_cli_output.json

# Retrieve the cluster ID from AWS CLI output
CLUSTER_ID="$(jq -r '.ClusterId' logs/aws_cli_output.json)"
printf "Cluster ID: $CLUSTER_ID\n\n"

# Wait until the cluster is created successfully. Exit if creation unsuccessful
python wait_until_cluster_created.py $CLUSTER_ID
if [ $? -eq 0 ]
then
  echo "Successfully created cluster"
else
  echo "Error in cluster creation" >&2
  exit 1
fi

# Get the server master DNS
aws emr describe-cluster --cluster-id $CLUSTER_ID > logs/cluster_description.json
MASTER_DNS="$(jq -r '.Cluster.MasterPublicDnsName' logs/cluster_description.json)"
printf "Master DNS: $MASTER_DNS\n"
printf "Cluster ID: $CLUSTER_ID\nMaster DNS: $MASTER_DNS\n" > logs/short_info.txt

# Make two scripts to easily SSH to server or connect to running notebook
printf "ssh -i $AWS_KEY hadoop@$MASTER_DNS\n" > connect_to_server.sh
printf "ssh -i $AWS_KEY -N -L 8080:localhost:8080 hadoop@$MASTER_DNS\n" > connect_to_notebook.sh

# Copy relevant files to the server
scp -i $AWS_KEY -o 'StrictHostKeyChecking no' $AWS_KEY hadoop@$MASTER_DNS:/home/hadoop/.ssh/id_rsa
scp -i $AWS_KEY -o 'StrictHostKeyChecking no' -r ../2.remote/ hadoop@$MASTER_DNS:/home/hadoop/

# Install hail prerequisites
ssh -i $AWS_KEY hadoop@$MASTER_DNS 'sh 2.remote/1.install_prereqs.sh'

# Install hail itself
ssh -i $AWS_KEY hadoop@$MASTER_DNS 'sh 2.remote/2.install_hail.sh'

if $RUN_JUPYTER ; then
    ssh -i $AWS_KEY hadoop@$MASTER_DNS 'sh 2.remote/3.run_jupyter.sh'
fi
