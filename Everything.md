# Spark 2 Notes

#### Table of Contents
- [Transformations vs Actions vs Commands](#Transformations%20vs%20Actions)
- [Coalesce vs Partition](#Coalesce%20vs%20Partition)
- [Cache vs Persist](#Cache%20vs%20Persist)
- [Distinct vs DropDuplicates](#Distinct%20vs%20DropDuplicates)
- [Printing RDD elements](#Printing%20RDD%20elements)
- [Shared Variables](#Shared%20Variables)
- [Important Notes](#Important%20Notes)


### Transformations vs Actions

- Actions return a value back to the driver program

- Transformations create a new dataset form an existing one

- Narrow transformations are the result of map, filter and such that is from the data from a single partition only, i.e. it is self-sustained. An output RDD has partitions with records that originate from a single partition in the parent RDD. Only a limited subset of partitions used to calculate the result. Spark groups narrow transformations as a stage which is called pipelining.

- Wide transformations are the result of groupByKey and reduceByKey. The data required to compute the records in a single partition may reside in many partitions of the parent RDD. Wide transformations are also called shuffle transformations as they may or may not depend on a shuffle. All of the tuples with the same key must end up in the same partition, processed by the same task. To satisfy these operations, Spark must execute RDD shuffle, which transfers data across cluster and results in a new stage with a new set of partitions.

- Optimzations done in the action, for improving the plan for all the transformations

#### Commands
<details>
  <summary> Click to expand </summary>

  * printSchema
  * cache - these 3 mark the dataframe to be remembered and are lazily evaulated
  * persist
  * unpersist

</details>

#### Actions
<details>
  <summary> Click to expand </summary>
 
  * count
  * take
  * top
  * first
  * countByValue
  * show
  * reduce
  * fold
  * foreach
  * getNumPartitions
  * collect
  * max
  * sum
  * mean
  * stdev
  * countByKey
  * saveAsTextFile

</details>

#### Narrow Transformations
<details>
  <summary> Click to expand </summary>
 
  * map
  * flatMap
  * select
  * drop
  * filter
  * limit
  * mapPartition
  * mapPartitionsWithIndex
  * keyBy
  * sample
  * union
  * zip
  * coalesce - reduces number of shuffles (DOES NOT balance data on partitions) (shuffle flag disabled by default)

</details>

#### Wide Transformations
<details>
  <summary> Click to expand </summary>
 
  * intersection
  * groupBy
  * sortBy
  * orderBy
  * groupByKey   
  * reduceByKey
  * agg
  * aggregate
  * aggregateBy
  * distinct
  * dropDuplicates
  * join
  * cogroup
  * cartesian
  * partitionBy
  * repartition - increase or decrease num partitions (unbalnaced partitions)
  
</details>
  
### Coalesce vs Partition
- coalesce(numPartitions): Decrease the number of partitions in the RDD to numPartitions. Useful for running operations more efficiently after filtering down a large dataset. Avoids full shuffles
- repartition(numPartitions):	Reshuffle the data in the RDD randomly to create either more or fewer partitions and balance it across them. This always shuffles all data over the network. 
  
### Cache vs Persist
- persist can save the dataframe data to any data source DISK_ONLY, MEMEORY_ONLY, ...
- cache just calls the persist function with choosing the datasource to be MEMORY_ONLY
- unpersist is a method but there is no uncache function, unpersist will do that (also will auto uncache if not used for a while)

### Distinct vs DropDuplicates
- The main difference is the consideration of the subset of columns which is great! When using distinct you need a prior .select to select the columns on which you want to apply the duplication and the returned Dataframe contains only these selected columns while dropDuplicates(colNames) will return all the columns of the initial dataframe after removing duplicated rows as per the columns

### Printing RDD elements
- Another common idiom is attempting to print out the elements of an RDD using rdd.foreach(println) or rdd.map(println). On a single machine, this will generate the expected output and print all the RDD’s elements. However, in cluster mode, the output to stdout being called by the executors is now writing to the executor’s stdout instead, not the one on the driver, so stdout on the driver won’t show these! To print all elements on the driver, one can use the collect() method to first bring the RDD to the driver node thus: rdd.collect().foreach(println). This can cause the driver to run out of memory, though, because collect() fetches the entire RDD to a single machine; if you only need to print a few elements of the RDD, a safer approach is to use the take(): rdd.take(100).foreach(println).

### Shared Variables
#### Accumulators
  - Accumulators provide a shared, mutable variable that a Spark cluster can safely update on a per-row basis. 
  - Can only increase
  - The Spark UI current only displays all named accumulators used by your application
  - Programmers can also create their own types of Accumulators by subclassing AccumulatorParam
  - For accumulator updates performed inside actions only, Spark guarantees that each task’s update to the accumulator will only be applied once, i.e. restarted tasks will not update the value. In transformations, users should be aware of that each task’s update may be applied more than once if tasks or job stages are re-executed.
  - Accumulators do not change the lazy evaluation model of Spark. If they are being updated within an operation on an RDD, their value is only updated once that RDD is computed as part of an action. Consequently, accumulator updates are not guaranteed to be executed when made within a lazy transformation like map()
#### Broadcast Variables
  - Reference passed to data instead of data itself
  - Adds a hint/marks the dataframe to be broadcasted (readonly only cached)
  - The broadcast keyword allows to mark a DataFrame that is SMALL enough to be used in broadcast joins.
  - Broadcast join large data with small data
  - Spark will attempt to auto broadcast join during any join operation. The default auto broadcast threshold is 10M 
  - Broadcast allows to send a read-only variable cached on each node once, rather than sending a copy for all tasks. 

### Important Notes
- MEMORY_ONLY: Store RDD as deserialized Java objects in the JVM. If the RDD does not fit in memory, some partitions will not be cached and will be recomputed on the fly each time they're needed. THIS IS THE DEFAULT LEVEL
-  In Python, stored objects will always be serialized with the Pickle library, so it does not matter whether you choose a serialized level. The available storage levels in Python include MEMORY_ONLY, MEMORY_ONLY_2, MEMORY_AND_DISK, MEMORY_AND_DISK_2, DISK_ONLY, and DISK_ONLY_2
- Spark also automatically persists some intermediate data in shuffle operations (e.g. reduceByKey), even without users calling persist. This is done to avoid recomputing the entire input if a node fails during the shuffle. We still recommend users call persist on the resulting RDD if they plan to reuse it
-  Using Structured Streaming, the file sink type is idempotent and can provide end-to-end EXACTLY-ONLY semantics in a Structured Streaming job. Kafka and foreach sinks are fault tolerant >= 1,  memory and console are not fault tolerant
- Using replayable sources and idempotent sinks, Structured Streaming can ensure end-to-end exactly-once semantics under any failure
- Spark also automatically persists some intermediate data in shuffle operations (e.g. reduceByKey), even without users calling persist. This is done to avoid recomputing the entire input if a node fails during the shuffle. We still recommend users call persist on the resulting RDD if they plan to reuse it.
- Tungsten is a Spark SQL component that provides increased performance by rewriting Spark operations in bytecode, at runtime. Tungsten suppresses virtual functions and leverages close to bare metal performance by focusing on jobs CPU and memory efficiency
- Explicit caching can decrease application performance by interferring with the Catalyst optimizer's ability to optimize some queries
- Change default number shuffle partitions `sqlContext.setConf("spark.sql.shuffle.partitions", "300")`



### Others
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
