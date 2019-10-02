#!/bin/sh
# Component to install Spark from nothing
# Written by Matt Stillwell

# Download binaries
sudo wget -P /opt -c http://apache.claz.org/spark/spark-2.4.3/spark-2.4.3-bin-hadoop2.7.tgz

# Extract binaries
sudo tar -zxf /opt/spark-2.4.3-bin-hadoop2.7.tgz -C /opt

# remove tar file 
#sudo rm /opt/spark-2.4.3-bin-hadoop2.7.tgz

# Export environment variables
export JAVA_HOME="/usr/lib/jvm/default-java"
export PYSPARK_PYTHON="python2"
export SPARK_HOME="/opt/spark-2.4.3-bin-hadoop2.7"
export PYTHONPATH="$PYTHONPATH:$SPARK_HOME/python"
export PATH="$PATH:$SPARK_HOME/bin"

# Make ~/.profile as user in case it doesn't exist already
touch ~/.profile

# Save environment settings in profile
echo "
# PYSPARK VARIABLES
export JAVA_HOME=/usr/lib/jvm/default-java
export PYSPARK_PYTHON=python2
export SPARK_HOME=/opt/spark-2.4.3-bin-hadoop2.7
export PYTHONPATH=$SPARK_HOME/python:"'$PYTHONPATH'"
export PATH=$SPARK_HOME/bin:"'$PATH'"
# PYSPARK VARIABLES END
" | sudo tee -a ~/.profile /etc/profile > /dev/null

# Tell user to source profile
echo -e "\e[1;32mLog out or run
source ~/.profile
to be sure your environment variables are set up correctly\e[m"

# Install python3
sudo apt install pip3-python

# Install python3 libs
pip3 install jupyter
pip3 install py4j
