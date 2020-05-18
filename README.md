# Running hail on AWS EMR

Updated 2020-05-18, by Michael Zietz

Loosely adapted from https://github.com/hms-dbmi/hail-on-AWS-spot-instances

## Step 0. Get an EC2 key pair (`.pem` file)

https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html

This has to be done online by someone with permissions.

## Step 1. Install AWS command line interface (CLI)

[OS-specific instructions](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html).
On Ubuntu 18.04, I did the following:

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

```bash
# Test install
$ aws --version
aws-cli/2.0.14 Python/3.7.3 Linux/5.3.0-40-generic botocore/2.0.0dev18
```

## Step 2. Configure AWS credentials

[Documentation from AWS](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)

`*`s here hide actual values. Lengths the same, letters and numbers changed.

```bash
$ aws configure
AWS Access Key ID [None]: A******************G
AWS Secret Access Key [None]: Q**********************D/A*************7
Default region name [None]: us-east-1
Default output format [None]: json
```

## Step 3. Configure cluster creation options

[Documentation from AWS](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/emr/create-cluster.html)

A. In `1.local/config/manual_configs.sh`, you'll need to change the name of the EC2 key, and maybe the S3 logging info.

B. In `1.local/config/instance_groups.json`, set details about the cluster you want to create (number of machines, number of CPUs, memory, etc.).
"Bid price" refers to spot instance bid pricing, which can sometimes be considerably cheaper.

C. `1.local/config/ec2_attributes.json` contains security group and role information.
Within the Tatonetti lab, there shouldn't be anything you need to change.

## Step 4. Create the cluster

```bash
cd 1.local
bash 1.create_cluster.sh
```
(This assumes you have Python installed)

In total, this takes ~20-30 minutes.
Most of that is AWS setting up EMR and compiling hail.
Once complete, you should see the terminal output from running a Jupyter notebook.
Make note of (either) URL shown, as the password will be needed to connect.

## Step 5. Connect to the server/notebook

You should now find two scripts in your current directory: `connect_to_server.sh` and `connect_to_notebook.sh`.

To run hail interactively in the Jupyter notebook, run `bash connect_to_notebook.sh`.
Then, in a browser, open the URL shown at the end of the `1.create_cluster.sh` script.

For easy SSH access to the cluster, run `bash connect_to_server.sh`.

I've added a notebook, `template.ipynb`, which imports hail.
Running the first cell is a good way to check that everything was installed properly.

## Complete: Using hail

An easy way to load UK Biobank data we have stored in S3 is to pass S3 addresses to functions like `hl.import_bgen`.
You can also write things to S3 in the same way.
For performance reasons, it will probably make more sense to deal with hail `MatrixTable`s, so I recommend conversions before running things.

[Hail Documentation](https://hail.is/docs/0.2/index.html)
