# My Spark 2.X Notes

#### Table of Contents
- [Method Categories](#Method_Categories)
- [Transformations vs Actions](#Transformations_vs_Actions)
- [Reading In Data](#Reading_In_Data)
- [Whats The Difference?](#Whats_The_Difference?)
- [Printing RDD elements](#Printing_RDD_elements)
- [Shared Variables](#Shared_Variables)
- [SQL](#SQL)
- [Windowing](#Windowing)
- [GraphFrames](#GraphFrames)
- [Machine Learning](#Machine_Learning)
- [Important Notes](#Important_Notes)


### Method_Categories

<details>
  <summary> Commands </summary>

  * printSchema
  * cache
  * persist
  * unpersist
  
</details>

<details>
  <summary> Actions </summary>
 
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

<details>
  <summary> Narrow Transformations </summary>
 
  * map
  * coalesce
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
  
</details>

<details>
  <summary> Wide Transformations </summary>
  
  * repartition
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
  * intersection
  * cogroup
  * cartesian
  * partitionBy
  
</details>


### Transformations_vs_Actions

- Actions return a value back to the driver program
- Transformations create a new dataset form an existing one
- Narrow transformations are the result of `map()`, `filter()` and such that is from the data from a single partition only, i.e. it is self-sustained. An output RDD has partitions with records that originate from a single partition in the parent RDD. Only a limited subset of partitions used to calculate the result. Spark groups narrow transformations as a stage which is called pipelining.
- Wide transformations are the result of `groupByKey()` and `reduceByKey()`. The data required to compute the records in a single partition may reside in many partitions of the parent RDD. Wide transformations are also called shuffle transformations as they may or may not depend on a shuffle. All of the tuples with the same key must end up in the same partition, processed by the same task. To satisfy these operations, Spark must execute RDD shuffle, which transfers data across cluster and results in a new stage with a new set of partitions.

- `read()` is not an action, however if the `inferSchema` option is set then it acts as one
- Optimzations done in the action, for improving the plan for all the transformations


### Reading_In_Data
- CSV 
  - TODO (params, output mode and format)

- Parquet
  - TODO (params)

- JSON
  - TODO (params)

- Custom
  - How create new reader? Add spark module?

- TODO


### Whats_The_Difference?

#### Coalesce vs Partition
- `coalesce(numPartitions)`: Decrease the number of partitions in the RDD to numPartitions. Useful for running operations more efficiently after filtering down a large dataset. Avoids full shuffles. `coalesce` only can decrease num partitions (does NOT balance data on partitions) (shuffle flag disabled by default)
- `repartition(numPartitions)`:	Reshuffle the data in the RDD randomly to create either more or fewer partitions and balance it across them. This always shuffles all data over the network. `repartion()` can increase or decrease num partitions (balanced partitions)
  
#### Cache vs Persist
- persist can save the dataframe data as any persistance level: `MEMORY_ONLY`, `MEMORY_ONLY_2`, `MEMORY_AND_DISK`, `MEMORY_AND_DISK_2`, `DISK_ONLY`, or `DISK_ONLY_2`
- cache just calls the persist function with choosing the persistance level to be `MEMORY_ONLY`
- unpersist is a method but there is no `uncache()` function, unpersist will do that (also will auto uncache if not used for a while)

#### Distinct vs DropDuplicates
- When using `distinct()` you need a prior `select(colNames)` to select the columns on which you want to apply the deduplication and the returned Dataframe contains only these selected columns. While `dropDuplicates(colNames)` will return all the columns of the initial dataframe after removing duplicated rows as per the columns

#### OrderBy vs Sort
- Completely the same, aliases for one another
- To sort by say 2 cols: `df.orderBy(desc("age"), "name").collect()`

#### First vs Head
- TODO

#### Filter vs Where
- TODO


### Printing_RDD_elements
- Another common idiom is attempting to print out the elements of an RDD using `rdd.foreach(println)` or `rdd.map(println)`. On a single machine, this will generate the expected output and print all the RDD’s elements. However, in cluster mode, the output to stdout being called by the executors is now writing to the executor’s stdout instead, not the one on the driver, so stdout on the driver won’t show these! To print all elements on the driver, one can use the `collect()` method to first bring the RDD to the driver node thus: `rdd.collect().foreach(println)`. This can cause the driver to run out of memory, though, because `collect()` fetches the entire RDD to a single machine; if you only need to print a few elements of the RDD, a safer approach is like this: `rdd.take(100).foreach(println)`


### Shared_Variables

#### Accumulators
- Accumulators provide a shared, mutable variable that a Spark cluster can safely update on a per-row basis. 
- Can only increase
- The Spark UI current only displays all named accumulators used by your application
- Programmers can also create their own types of Accumulators by subclassing `AccumulatorParam`
- For accumulator updates performed inside actions only, Spark guarantees that each task’s update to the accumulator will only be applied once, i.e. restarted tasks will not update the value. In transformations, users should be aware of that each task’s update may be applied more than once if tasks or job stages are re-executed.
- Accumulators do not change the lazy evaluation model of Spark. If they are being updated within an operation on an RDD, their value is only updated once that RDD is computed as part of an action. Consequently, accumulator updates are not guaranteed to be executed when made within a lazy transformation like `map()`
- Problem with accumlators. Accumulators optimized?

#### Broadcast Variables
- Reference passed to data instead of data itself
- Adds a hint/marks the dataframe to be broadcasted (readonly only cached)
- The broadcast keyword allows to mark a DataFrame that is SMALL enough to be used in broadcast joins.
- Broadcast join large data with small data
- Spark will attempt to auto broadcast join during any join operation. The default auto broadcast threshold is 10M 
- Broadcast allows to send a read-only variable cached on each node once, rather than sending a copy for all tasks. 


### SQL
- Convert df into a temporary table view: `myDF.createOrReplaceTempView("people")`
- Then use SQL like `anotherDF = spark.sql("SELECT * FROM people")`


### Windowing
- TODO (params)


### GraphFrames
- Fully review this [notebook](https://docs.databricks.com/spark/latest/graph-analysis/graphframes/user-guide-python.html)
- `GraphFrame(verticesDF, edgesDF)` where verticesDF has `id` column and edgesDF has `src` and `dst` columns
- Breadth-first search `g.bfs("name = 'Esther'", "age < 32")` or `g.bfs(fromExpr = "name = 'Esther'", toExpr = "age < 32", edgeFilter = "relationship != 'friend'", maxPathLength = 3)`
- `triangleCount()` is how many loop backs the node has to itself
- `graphframe.degrees()` = df(sum(inDegrees + outDegrees))
- `pageRank(resetProbability=0.15, tol=0.01)`, `connectedComponents(maxIter)` (tolerance) and `stronglyConnectedComponents(maxIter)` are all values showing how the vertex is connected within the graph
- `labelPropagation(maxIter)` assigns groupings of similarly connected vertices
- Shortest Path algorithm `g.shortestPaths(landmarks=["a", "d"])`
- Motif finding is a search given a set of generic vertices and their connections to other vertices `g.find("(a)-[e]->(b); (b)-[e2]->(a)")`


### Machine_Learning
- TODO
- Pipeline featurizer bottleneck?


### Important_Notes
- `MEMORY_ONLY`: Store RDD as deserialized Java objects in the JVM. If the RDD does not fit in memory, some partitions will not be cached and will be recomputed on the fly each time they're needed. __This is the default persistance level__
-  In Python, stored objects will always be serialized with the Pickle library, so it does not matter whether you choose a serialized level. The available storage levels in Python include `MEMORY_ONLY`, `MEMORY_ONLY_2`, `MEMORY_AND_DISK`, `MEMORY_AND_DISK_2`, `DISK_ONLY`, and `DISK_ONLY_2`
- Spark also automatically persists some intermediate data in shuffle operations (e.g. reduceByKey), even without users calling persist. This is done to avoid recomputing the entire input if a node fails during the shuffle. We still recommend users call persist on the resulting RDD if they plan to reuse it
-  Using Structured Streaming, the file sink type is idempotent and can provide end-to-end EXACTLY-ONLY semantics in a Structured Streaming job. Kafka and foreach sinks are fault tolerant >= 1,  memory and console are not fault tolerant
- Using replayable sources and idempotent sinks, Structured Streaming can ensure end-to-end exactly-once semantics under any failure
- Tungsten is a Spark SQL component that provides increased performance by rewriting Spark operations in bytecode, at runtime. Tungsten suppresses virtual functions and leverages close to bare metal performance by focusing on jobs CPU and memory efficiency
- Explicit caching can decrease application performance by interferring with the Catalyst optimizer's ability to optimize some queries
- Change default number shuffle partitions `sqlContext.setConf("spark.sql.shuffle.partitions", "300")`
- `cache()`, `persist(level)` and `unpersist()` are all lazily evaluated
- baseRDD is the initial RDD of the read-in data 
- Catalyst optimizer with rewrite your transfomations for you, so if you say `drop(colA)` and then try to `withColumnRenamed(colA, colB)` it will not throw an error it will just ignore both of these lines. However if try comparing equality of a dropped col then it will thow an error because it is trying to accesss the nonexistant values of it
- In Spark SQL, it works correctly and the same to specifiy `WHERE AGE == 10` and `WHERE AGE == '10'`
- When accessing elements from a tuple tup[0] is the corresponding data element in col 1 and tup[1] would be for the data element in col 2  
- `split(col('text'), "")` Splits the sentence into letters array. So `split(“”)[0]` is the first letter
- `explode()` takes an array and seperates each element onto a new row
- In the case of Python, the cleanest version is the `col("column-name")` variant as opposed to just specifying colName or `df[colName]`(dictionary mode). It more efficently calls the column directly
- The number of partitions used in Spark is configurable and having too few (causing less concurrency, data skewing and improper resource utilization) or too many (causing task scheduling to take more time than actual execution time) partitions is not good
- DataFrames do NOT have a `tail()` method
- The number of tasks and number of partitions should be a __multiple__ of the number of cores


### Others
- Scala akka
- Spark heap as much memory as mapreduce?
- Reduce by key bottleneck
- Doesn’t scale Horizontally? Stand alone, local, mesos, yarn
- When triggered accumulators
- How to change value of an rdd
