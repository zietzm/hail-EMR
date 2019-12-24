#!/bin/bash

# Set variables using manual configurations
. ./config/manual_configs.sh

# Activate conda environment (for AWS CLI)
eval "$(conda shell.bash hook)"
conda env create -f environment.yml
conda activate hail-local

mkdir -p logs

# Create EMR cluster using spot instances
aws emr create-cluster \
--applications Name=Ganglia Name=Hadoop Name=Spark \
--name "'$CLUSTER_NAME'" \
--service-role EMR_DefaultRole \
--auto-scaling-role EMR_AutoScaling_DefaultRole \
--release-label emr-5.28.0 \
--ec2-attributes file://config/ec2_attributes.json \
--ebs-root-volume-size 32 \
--instance-groups file://config/instance_groups.json \
--configurations '[{"Classification":"spark","Properties":{"maximizeResourceAllocation":"true"}}]' \
--scale-down-behavior TERMINATE_AT_TASK_COMPLETION \
--region us-east-1 \
--enable-debugging \
--log-uri "'$LOG_URI'" \
> logs/aws_cli_output.json

# Retrieve the cluster ID from AWS CLI output
CLUSTER_ID="$(jq -r '.ClusterId' logs/aws_cli_output.json)"
echo "Cluster ID: $CLUSTER_ID\n"

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
echo "Master DNS: $MASTER_DNS"

# Copy relevant files to the server
scp -i $AWS_KEY -o 'StrictHostKeyChecking no' $AWS_KEY hadoop@$MASTER_DNS:/home/hadoop/.ssh/id_rsa
scp -i $AWS_KEY -o 'StrictHostKeyChecking no' -r ../2.remote/ hadoop@$MASTER_DNS:/home/hadoop/

# Install hail and run the notebook
ssh -i $AWS_KEY hadoop@$MASTER_DNS 'sh 2.remote/1.install_hail.sh'

if [ "$run_jupyter" = true ] ; then
    ssh -i $AWS_KEY hadoop@$MASTER_DNS 'sh 2.remote/2.run_jupyter.sh'
fi
