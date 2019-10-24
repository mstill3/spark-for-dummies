# PySpark 2.x Notes

## Transformations vs Actions


Narrow transformations are the result of map, filter and such that is from the data from a single partition only, i.e. it is self-sustained.

An output RDD has partitions with records that originate from a single partition in the parent RDD. Only a limited subset of partitions used to calculate the result.

Spark groups narrow transformations as a stage which is called pipelining.


Wide transformations are the result of groupByKey and reduceByKey. The data required to compute the records in a single partition may reside in many partitions of the parent RDD.
Note
	Wide transformations are also called shuffle transformations as they may or may not depend on a shuffle.

All of the tuples with the same key must end up in the same partition, processed by the same task. To satisfy these operations, Spark must execute RDD shuffle, which transfers data across cluster and results in a new stage with a new set of partitions.


Optimzations done in the action, for improving the plan for all the transformations


#### Other
  * printSchema

#### Narrow Transformations
  * map
  * flatMap
  * filter
  * mapPartition
  * mapPartitionsWithIndex
  * keyBy
  * sample
  * union
  * zip
    
#### Wide Transformations
  * intersection
  * groupBy
  * groupByKey
  * aggregateBy
  * distinct
  * reduceByKey
  * join
  * cartesian
  * partitionBy
  * repartition - increase or decrease num partitions (unbalnaced partitions)
  * coalesce - reduces number of shuffles (balances data on partitions)
    
#### Actions
  * count
  * take
  * top
  * countByValue
  * show
  * reduce
  * fold
  * agg
  * foreach
  * getNumPartitions
  * collect
  * aggregate
  * max
  * sum
  * mean
  * stdev
  * countByKey
  * saveAsTextFile
  

