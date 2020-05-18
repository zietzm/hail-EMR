#!/bin/bash

source $HOME/miniconda/etc/profile.d/conda.sh
conda activate hail-remote

export HAIL_HOME=$(pip show hail | grep Location | awk -F' ' '{print $2 "/hail"}')
export PYSPARK_DRIVER_PYTHON=jupyter
export PYSPARK_DRIVER_PYTHON_OPTS='notebook --no-browser --port=8080'
source ~/.bashrc

# Add hail .jar to the spark configuration (hail asks for this, even though
# --jars should be sufficient per the Spark documentation), and add other
# hail options
sed "/^spark.driver.extraClassPath/ s|$|\:$HAIL_HOME/backend/hail-all-spark.jar|" /etc/spark/conf/spark-defaults.conf |
sed "/^spark.executor.extraClassPath/ s|$|\:$HAIL_HOME/backend/hail-all-spark.jar|" |
sed "\$aspark.serializer\torg.apache.spark.serializer.KryoSerializer" |
sed "\$aspark.kryo.registrator\tis.hail.kryo.HailKryoRegistrator" > /etc/spark/conf/spark-defaults.conf

pyspark \
  --jars $HAIL_HOME/backend/hail-all-spark.jar

  # hail docs list this as well, but not sure why it'd be necessary
  # --conf spark.jars=$HAIL_HOME/backend/hail-all-spark.jar
