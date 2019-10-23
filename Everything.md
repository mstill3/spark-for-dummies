# PySpark 2.x Notes

## Transformations vs Actions
Narrow transformation – In Narrow transformation, all the elements that are required to compute the records in single partition live in the single partition of parent RDD. A limited subset of partition is used to calculate the result. Narrow transformations are the result of map(), filter().  
Wide transformation – In wide transformation, all the elements that are required to compute the records in the single partition may live in many partitions of parent RDD. The partition may live in many partitions of parent RDD. Wide transformations are the result of groupbyKey() and reducebyKey().    

#### Narrow Transformations
  * map
  * flatMap
  * filter
  * mapPartition
  * sample
  * union
    
#### Wide Transformations
  * intersection
  * distinct
  * reduceByKey
  * join
  * cartesian
  * repartition
  * coalesce
    
#### Actions
  * count
  * take
  * top
  * countByValue
  * reduce
  * fold
  * agg
  * foreach

