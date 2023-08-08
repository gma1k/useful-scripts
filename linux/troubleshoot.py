#!/usr/bin/env python3
import sys
import os
import datetime
import subprocess
import re

from pyspark import SparkContext
from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from pyspark.sql.types import *

sc = SparkContext(appName="Log Analysis")

spark = SparkSession.builder.getOrCreate()

log_file1 = "/path/to/log/file1.log"
log_file2 = "/path/to/log/file2.log"
log_file3 = "/path/to/log/file3.log"

log_df = spark.read.text(log_file1, log_file2, log_file3)

pattern = r"(\d{2} \w{3} \d{2}:\d{2}) (\w+) (\w+)"

def parse_line(line):
  match = re.search(pattern, line)
  if match:
    return list(match.groups())
  else:
    return None

schema = StructType([
  StructField("date_time", StringType(), True),
  StructField("service", StringType(), True),
  StructField("action", StringType(), True)
])

log_df = log_df.withColumn("parsed", udf(parse_line, schema)("value")).select("parsed.*")

log_df = log_df.withColumn("date_time", to_timestamp("date_time", "dd MMM HH:mm"))

restarts_df = log_df.filter(log_df.action == "restarted").groupBy("service").count()

latest_df = log_df.filter(log_df.action == "restarted").groupBy("service").agg(max("date_time").alias("latest"))

result_df = restarts_df.join(latest_df, "service")

result_df.show()

print("The system and application have some issues with restarting the services.")
for row in result_df.collect():
  print(f"{row.service} has restarted {row.count} times, with the latest restart at {row.latest}.")
print("The system administrator should investigate the root cause of these restarts and fix them as soon as possible.")
