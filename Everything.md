# PySpark 2.x Notes

## Transformations vs Actions
Narrow transformation – In Narrow transformation, all the elements that are required to compute the records in single partition live in the single partition of parent RDD. A limited subset of partition is used to calculate the result. Narrow transformations are the result of map(), filter().  
Wide transformation – In wide transformation, all the elements that are required to compute the records in the single partition may live in many partitions of parent RDD. The partition may live in many partitions of parent RDD. Wide transformations are the result of groupbyKey() and reducebyKey().    


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
  * distinct
  * reduceByKey
  * join
  * cartesian
  * partitionBy
  * repartition
  * coalesce
    
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
  

