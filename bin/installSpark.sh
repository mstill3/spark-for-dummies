#!/bin/sh
# Component to install Spark from nothing
# Written by Matt Stillwell

# Make spark directory
sudo mkdir -p /opt/spark/

# Download binaries to directory
sudo wget -P /opt/spark/ -c http://apache.mirrors.pair.com/spark/spark-2.4.4/spark-2.4.4-bin-hadoop2.7.tgz

# Extract binaries
sudo tar -zxf /opt/spark/spark-2.4.4-bin-hadoop2.7.tgz -C /opt/spark/

# Create current link
sudo ln -s /opt/spark/spark-2.4.4-bin-hadoop2.7 /opt/spark/spark-current

# remove tar file 
sudo rm /opt/spark/spark-2.4.4-bin-hadoop2.7.tgz

# Export environment variables
export JAVA_HOME="/usr/lib/jvm/default-java"
export PYSPARK_PYTHON="python2"
export SPARK_HOME="/opt/spark/spark-current"
export PYTHONPATH="$PYTHONPATH:$SPARK_HOME/python"
export PATH="$PATH:$SPARK_HOME/bin"

# Save environment settings in bashrc
echo "
# PYSPARK VARIABLES
export JAVA_HOME=/usr/lib/jvm/default-java
export PYSPARK_PYTHON=python2
export SPARK_HOME=/opt/spark/spark-current
export PYTHONPATH=$SPARK_HOME/python:"'$PYTHONPATH'"
export PATH=$SPARK_HOME/bin:"'$PATH'"
# PYSPARK VARIABLES END
" | sudo tee -a ~/.bashrc > /dev/null
