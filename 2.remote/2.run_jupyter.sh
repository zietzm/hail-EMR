#!/bin/bash

export HAIL_HOME=$(pip show hail | grep Location | awk -F' ' '{print $2 "/hail"}')
export PYSPARK_DRIVER_PYTHON=jupyter
export PYSPARK_DRIVER_PYTHON_OPTS='notebook --no-browser --port=8080'
source ~/.bashrc

pyspark \
  --jars $HAIL_HOME/hail-all-spark.jar \
  --conf spark.driver.extraClassPath=$HAIL_HOME/hail-all-spark.jar \
  --conf spark.executor.extraClassPath=./hail-all-spark.jar \
  --conf spark.serializer=org.apache.spark.serializer.KryoSerializer \
  --conf spark.kryo.registrator=is.hail.kryo.HailKryoRegistrator
