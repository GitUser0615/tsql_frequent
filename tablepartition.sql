/* The sys.partitions catalog view gives a list of all partitions for tables and most indexes. 
   Just JOIN that with sys.tables to get the tables.
   All tables have at least one partition, so if you are looking specifically for partitioned tables, 
   then you'll have to filter this query based off of sys.partitions.partition_number <> 1 (for non-partitioned tables, 
   the partition_number is always equal to 1).
*/

USE [database]
GO

BEGIN
    select distinct t.name from sys.partitions p
    inner join sys.tables t
    on p.object_id = t.object_id
    where p.partition_number <> 1
END


/* OR */

/*
This looks at the 'proper' place to identify the partition scheme: sys.partition_schemes, 
it has the right cardinality (no need for distinct), it shows only partitioned object (no need for a filtering where clause), 
it projects the schema name and partition scheme name. 
Note also how this query highlights a flaw on the original question: it is not tables that are partitioned, 
but indexes (and this includes index 0 and 1, aka. heap and clustered index). 
A table can have multiple indexes, some partitioned some not.
*/

USE [database]
GO

BEGIN
    select object_schema_name(i.object_id) as [schema],
    object_name(i.object_id) as [object],
    i.name as [index],
    s.name as [partition_scheme]
    from sys.indexes i
    join sys.partition_schemes s on i.data_space_id = s.data_space_id
END