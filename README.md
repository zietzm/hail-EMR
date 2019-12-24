# Running hail on ElasticMapReduce

## Minimal usage

Suggested steps to effectively starting a Jupyter notebook.

0. Clone this repository

```bash
git clone https://github.com/zietzm/hail-EMR.git
```

1. Ensure that you have `conda` installed.
We recommend [Miniconda](https://docs.conda.io/en/latest/miniconda.html), a lightweight distribution.

2. Ensure that you have a [configured AWS command line interface](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html#cli-quick-configuration).
This can be checked with `aws configure`.
If `aws configure` does not work, I suggest:

```bash
conda env create -f 1.local/environment.yml
conda activate hail-local
aws configure
```

3. Setup your manual configurations.
See [AWS Docs](https://docs.aws.amazon.com/cli/latest/reference/emr/create-cluster.html) for more information on these options.
    * `1.local/config/manual_configs.sh` - modify the manual configuration options
    * `1.local/config/` - modify the configuration files there, as needed.
    `ec2_attributes.json` will need modification.

4. Create the cluster.
Minimally:

```bash
cd 1.local
sh 1.create_cluster.sh
```

will create a cluster, install hail, and run a Jupyter notebook.

5. Connect to the notebook, using SSH/port forwarding:

```bash
MASTER_DNS="$(jq -r '.Cluster.MasterPublicDnsName' 1.local/logs/cluster_description.json)"
ssh -N -L 8080:localhost:8080 hadoop@$MASTER_DNS
```

Then in your internet browser go to <https://127.0.0.1:8080>, where a remote Jupyter notebook session can now be reached.

## More maximal usage

To effectively use hail on AWS, you may need to transfer data or to use additional packages, beyond the minimal `conda` environment that will be installed on the EMR cluster.
Both these tasks can be done easily, provided enough storage space was allocated to the cluster.
```bash
scp -i $AWS_KEY $path_to_files hadoop@$MASTER_DNS
```

In general, simply ssh to the cluster and install or download as necessary.
