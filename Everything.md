# My Spark 2.X Notes

### Table of Contents
- [Method Categories](#Method_Categories)
- [Transformations vs Actions](#Transformations_vs_Actions)
- [Reading In Data](#Reading_In_Data)
- [Writing Out Data](#Writing_Out_Data)
- [Method Distinctions](#Method_Distinctions)
- [Shared Variables](#Shared_Variables)
- [SQL](#SQL)
- [Windowing](#Windowing)
- [RDD](RDD)
- [GraphFrames](#GraphFrames)
- [Machine Learning](#Machine_Learning)
- [Akka](#Akka)
- [Important Notes](#Important_Notes)


### Method_Categories
Test your method distinct skills [here](https://quizlet.com/447819496/spark-2-flash-cards/)

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

<details>
  <summary> Relational Grouped Dataset Actions </summary>
  
  * avg
  * count
  * sum
  * min
  * max
  * mean
  * agg
  * pivot
  
</details>



### Transformations_vs_Actions

- Actions return a value back to the driver program
- Transformations create a new dataset from an existing one
- Narrow transformations are the result of `map()`, `filter()` and such that is from the data from a single partition only, i.e. it is self-sustained. An output RDD has partitions with records that originate from a single partition in the parent RDD. Only a limited subset of partitions used to calculate the result. Spark groups narrow transformations as a stage which is called pipelining.
- Wide transformations are the result of `groupByKey()` and `reduceByKey()`. The data required to compute the records in a single partition may reside in many partitions of the parent RDD. Wide transformations are also called shuffle transformations as they may or may not depend on a shuffle. All of the tuples with the same key must end up in the same partition, processed by the same task. To satisfy these operations, Spark must execute RDD shuffle, which transfers data across cluster and results in a new stage with a new set of partitions.

- `read()` is not an action, however if the `inferSchema` option is set then it acts as one
- Optimzations done in the action, for improving the plan for all the transformations


### Reading_In_Data
- Works with jdbc, text, json, orc, parquet, csv, table
- Format example: `spark.read.format('json').load('python/test_support/sql/people.json') `
- `spark.read.*`

#### CSV 
- Slow inference speed
- There are a large number of options when reading CSV files including headers, column separator, escaping, etc.
- We can allow Spark to infer the schema at the cost of first reading in the entire file.
- Large CSV files should always have a schema pre-defined.

#### Parquet
- Medium/Fast inference speed
- Parquet files are the preferred file format for big-data.
- It is a columnar file format.
- It is a splittable file format.
- It offers a lot of performance benefits over other formats including predicate pushdown.
- Unlike CSV, the schema is read in, not inferred.
- Reading the schema from Parquet's metadata can be extremely efficient.

#### Tables
- No inference, carried over
- The Databricks platform allows us to register a huge variety of data sources as tables via the Databricks UI.
- Any DataFrame (from CSV, Parquet, whatever) can be registered as a temporary view.
- Tables/Views can be loaded via the DataFrameReader to produce a DataFrame
- Tables/Views can be used directly in SQL statements.

#### JSON
- Slow inference speed
- JSON represents complex data types unlike CSV's flat format.
- Has many of the same limitations as CSV (needing to read the entire file to infer the schema)
- Like CSV has a lot of options allowing control on date formats, escaping, single vs. multiline JSON, etc.

#### Text
- No inference, no need just straight text
- Reads one line of text as a single column named value.
- Is the basis for more complex file formats such as fixed-width text files.

#### JDBC
- Fast inference speed
- Requires one database connection per partition.
- Has the potential to overwhelm the database.
- Requires specification of a stride to properly balance partitions.

### Data Stream
- Works with jdbc, text, json, orc, parquet, csv, table
- Example: `spark.readStream.format("text")`

#### Custom
- Write custom class that implements the Datasource API

### Writing_Out_Data

#### Streaming
- forEach example: `sdf.writeStream.foreach(print_row)`
- forEachBatch example: `sdf.writeStream.foreachBatch(func)`
- option only has timezone
- outputMode has append, complete, update. An example: `sdf.writeStream.outputMode('append')`
- start exmaple: `sq = sdf.writeStream.trigger(processingTime='5 seconds').start(queryName='that_query', outputMode="append", format='memory')`
- trigger(processingTime, once). processingTime is a string like '0 second' or '0 seconds' or '0 minute' or '0 minutes' and once is for 1 batch of data. An example: `writer = sdf.writeStream.trigger(processingTime='5 seconds')`


### Method_Distinctions

#### Coalesce vs Partition
- `coalesce(numPartitions)`: Decrease the number of partitions in the RDD to numPartitions. Useful for running operations more efficiently after filtering down a large dataset. Avoids full shuffles. `coalesce` only can decrease num partitions (does NOT balance data on partitions) (shuffle flag disabled by default)
- `repartition(numPartitions)`:	Reshuffle the data in the RDD randomly to create either more or fewer partitions and balance it across them. This always shuffles all data over the network. `repartion()` can increase or decrease num partitions (balanced partitions)
  
#### Cache vs Persist
- persist can save the dataframe data as any persistance level: `MEMORY_ONLY`, `MEMORY_ONLY_2`, `MEMORY_AND_DISK`, `MEMORY_AND_DISK_2`, `DISK_ONLY`, or `DISK_ONLY_2`
- cache just calls the persist function with choosing the persistance level to be `MEMORY_ONLY`
- unpersist is a method but there is no `uncache()` function, unpersist will do that (also will auto uncache if not used for a while)

#### Distinct vs DropDuplicates
- When using `distinct()` you need a prior `select(colNames)` to select the columns on which you want to apply the deduplication and the returned Dataframe contains only these selected columns. While `dropDuplicates(colNames)` will return all the columns of the initial dataframe after removing duplicated rows as per the columns

#### When vs Otherwise
- `when()` is the if and `otherwise()` is the else
- Example: `df.select(df.name, F.when(df.age > 3, 1).otherwise(0)).show()`

#### First vs Head
- `first()` will only return the first row
- `head(n)` can return n top rows

#### OrderBy vs Sort
- Completely the same, aliases for one another
- To sort by say 2 cols: `df.orderBy(desc("age"), "name").collect()`

#### Filter vs Where
- Completely the same, aliases for one another
- An example: `filteredDF = (sortedDescDF.filter( col("project") == "en"))`


### Shared_Variables

#### Accumulators
- Accumulators provide a shared, mutable variable that a Spark cluster can safely update on a per-row basis. 
- Can only increase
- The Spark UI current only displays all named accumulators used by your application
- Programmers can also create their own types of Accumulators by subclassing `AccumulatorParam`
- For accumulator updates performed inside actions only, Spark guarantees that each task’s update to the accumulator will only be applied once, i.e. restarted tasks will not update the value. In transformations, users should be aware of that each task’s update may be applied more than once if tasks or job stages are re-executed.
- Accumulators do not change the lazy evaluation model of Spark. If they are being updated within an operation on an RDD, their value is only updated once that RDD is computed as part of an action. Consequently, accumulator updates are not guaranteed to be executed when made within a lazy transformation like `map()`

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


### RDD
- RDD's are immutable so they cannot be changed directly.
- RDD's can be 'changed' by setting it to an editted existing rdd 
- An example: `rdd = rdd.map(lambda word: (word, 1))`



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

- Pipeline featurizer bottleneck?

#### Basic statistics
- summary statistics
- correlations
- stratified sampling
- hypothesis testing
- random data generation

#### Classification and regression
- linear models (SVMs, logistic regression, linear regression)
- naive Bayes
- decision trees
- ensembles of trees (Random Forests and Gradient-Boosted Trees)

#### Collaborative filtering
- alternating least squares (ALS)

#### Clustering
- k-means

#### Dimensionality reduction
- singular value decomposition (SVD)
- principal component analysis (PCA)

#### Feature extraction and transformation Optimization (developer)
- stochastic gradient descent
- limited-memory BFGS (L-BFGS)


### Cluster Managers
- All three cluster managers provide various scheduling capabilities but Apache Mesos provides the finest grained sharing options.
- High availability is offered by all three cluster managers but Hadoop YARN doesn’t need to run a separate ZooKeeper Failover Controller.
- Security is provided on all of the managers. Apache Mesos uses a pluggable architecture for its security module with the default module using Cyrus SASL. The Standalone cluster manager uses a shared secret and Hadoop YARN uses Kerberos. All three use SSL for data encryption.
- Finally, the Apache Standalone Cluster Manager is the easiest to get started with and provides a fairly complete set of capabilities. The scripts are simple and straightforward to use. So, if developing a new application this is the quickest way to get started.


### Akka
- Apache Spark is actually built on Akka.
- Akka is a general purpose framework to create reactive, distributed, parallel and resilient concurrent applications in Scala or Java. Akka uses the Actor model to hide all the thread-related code and gives you really simple and helpful interfaces to implement a scalable and fault-tolerant system easily. A good example for Akka is a real-time application that consumes and process data coming from mobile phones and sends them to some kind of storage.
- Apache Spark (not Spark Streaming) is a framework to process batch data using a generalized version of the map-reduce algorithm. A good example for Apache Spark is a calculation of some metrics of stored data to get a better insight of your data. The data gets loaded and processed on demand.
- Apache Spark Streaming is able to perform similar actions and functions on near real-time small batches of data the same way you would do it if the data would be already stored.
- I believe that as of Spark 1.6 Spark no longer uses Akka - Akka was replaced by Netty. Regardless, Spark used Akka only for communicating between nodes, not processing


### Important_Notes
- `MEMORY_AND_DISK`: (For DataFrames) __This is the default persistance level for DataFrames__
- `MEMORY_ONLY`: (For RDDs) Store RDD as deserialized Java objects in the JVM. If the RDD does not fit in memory, some partitions will not be cached and will be recomputed on the fly each time they're needed. __This is the default persistance level for RDDs__
-  In Python, stored objects will always be serialized with the Pickle library, so it does not matter whether you choose a serialized level. The available storage levels in Python include `MEMORY_ONLY`, `MEMORY_ONLY_2`, `MEMORY_AND_DISK`, `MEMORY_AND_DISK_2`, `DISK_ONLY`, and `DISK_ONLY_2`
- Spark also automatically persists some intermediate data in shuffle operations (e.g. reduceByKey), even without users calling persist. This is done to avoid recomputing the entire input if a node fails during the shuffle. We still recommend users call persist on the resulting RDD if they plan to reuse it
-  Using Structured Streaming, the file sink type is idempotent and can provide end-to-end EXACTLY-ONLY semantics in a Structured Streaming job. Kafka and foreach sinks are fault tolerant >= 1,  memory and console are not fault tolerant
- Using replayable sources and idempotent sinks, Structured Streaming can ensure end-to-end exactly-once semantics under any failure
- Another common idiom is attempting to print out the elements of an RDD using `rdd.foreach(println)` or `rdd.map(println)`. On a single machine, this will generate the expected output and print all the RDD’s elements. However, in cluster mode, the output to stdout being called by the executors is now writing to the executor’s stdout instead, not the one on the driver, so stdout on the driver won’t show these! To print all elements on the driver, one can use the `collect()` method to first bring the RDD to the driver node thus: `rdd.collect().foreach(println)`. This can cause the driver to run out of memory, though, because `collect()` fetches the entire RDD to a single machine; if you only need to print a few elements of the RDD, a safer approach is like this: `rdd.take(100).foreach(println)`
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
- Spark is 100x faster in memory and 10x faster on disk (heap) than mapreduce
- `reduceByKey()` is a bottleneck because it is a wide transformation
- When we shuffle data, it creates what is known as a stage boundary. Stage boundaries represent a process bottleneck.
- So what is the benefit of working backward through your action's lineage? Answer: It allows Spark to determine if it is necessary to execute every transformation.
