"""
    This script is a solution to the IP counting by analyzing a given
    log file using Spark.

    Note:   for this to work, you must add code to initialize 'spark'
            variable used in the code.

    Recommended usage:
        Use Google Colab.

        Step1: initialize spark.
        Step2: copy this code.
        Step3: configure file paths.
            Recommended defaults:
                logs_path = "/content/server_logs.log"
                output_path = "/content/ip_count.json"
    Credits:
        Zero credits to AI except for the help learning MapReduce/Spark.
"""

# Initialize file paths.

logs_path = "<path>"
output_path = "<path>"

# Load the records from the file to spark.

logs_rdd = spark.sparkContext.textFile(logs_path, minPartitions=4)

# Apply map which emits (ip, 1).
# In a log record:
#   log.substring.until( index_of( first_space ) ) = ip
# The function for map is based on this observation.

ips_rdd = logs_rdd.map(
    lambda log: (
      log[:log.index(" ")], 1
    )
)

# Apply reduce: shuffles by keys into partitions & combines items by their key.

ip_counts_rdd = ips_rdd.reduceByKey(lambda k1, k2: k1 + k2)

# Collect the final result.

ip_counts = ip_counts_rdd.collect()

# Create a dict form of the result.

ip_counts_dict = {
    ip: count for ip, count in ip_counts
}

# Save to a 'json' file.

import json

with open(output_path, "w") as output_file:
  json.dump(ip_counts_dict, output_file, indent=4)
