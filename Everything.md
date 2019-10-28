# Spark 2 Notes

## Transformations vs Actions
<details>
  <summary> Click to expand </summary>

- Narrow transformations are the result of map, filter and such that is from the data from a single partition only, i.e. it is self-sustained. An output RDD has partitions with records that originate from a single partition in the parent RDD. Only a limited subset of partitions used to calculate the result. Spark groups narrow transformations as a stage which is called pipelining.

- Wide transformations are the result of groupByKey and reduceByKey. The data required to compute the records in a single partition may reside in many partitions of the parent RDD. Wide transformations are also called shuffle transformations as they may or may not depend on a shuffle. All of the tuples with the same key must end up in the same partition, processed by the same task. To satisfy these operations, Spark must execute RDD shuffle, which transfers data across cluster and results in a new stage with a new set of partitions.

- Optimzations done in the action, for improving the plan for all the transformations

- Examples
  - Commands
    * printSchema
    * cache
    * persist
    * unpersist
  - Actions
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
  - Transformations (limit, select, drop, dropDuplicates)
    - Narrow
      * map
      * flatMap
      * filter
      * mapPartition
      * mapPartitionsWithIndex
      * keyBy
      * sample
      * union
      * zip
      * coalesce - reduces number of shuffles (balances data on partitions) (shuffle flag disabled by default)
    - Wide
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
    
</details>
  
## Cache vs Persist
- persist can save the dataframe data to any data source DISK, MEMEORY, ...
- cache just calls the persist function with choosing the datasource to be MEMEORY
- unpersist is a method but there is no uncache function, unpersist will do that

## Others
- Graph frame bfs inexpression Params
- Problem with accumlators
- How many tasks should u have in relation to num cores? Equal or multiple  
- Practice with Integer comparison SQL query 
- Set shuffle partitions
- Scala akka
- Spark heap 2 as much men as mapreduce
- How create new reader? Add spark module?
- Baserdd
- Pipeline featurizer bottleneck
- Reduce by key bottleneck
- Pulling values form tuple
- How to use broadcast join
- Error with too many partitions
- Ddfualt persistence mode 
- Doesn’t scale Horizontally? Stand alone, local, mesos, yarn
- How to change partitions
- Split explode
- Rename column compare
- When does red triggered in code? Actions
- When triggered accumulators
- Reader format with output mode and format
- Correct window parameters
- How to change value of an rdd
- Dictionary mode pull df value is bad for large data 
- Split(“”)[0] first letter or word?
- Accumulators optimized
