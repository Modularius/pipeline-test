from typing import Optional, Tuple, List, Dict, Any
import frame.frame_assembler as fa
import frame.frame as fr
from datetime import datetime
from elasticsearch import Elasticsearch
import json
import matplotlib.pyplot as plt
from matplotlib.ticker import MultipleLocator
import numpy as np
from lib import ESQuery

### Data Gathering
def do_counting(client, index: str, eq_query: ESQuery, service_name: str, op_name: str, fields: List[str]) -> List[Tuple[int,int]]:
    serviceName_query = { "term": { "process.serviceName": service_name } }
    op_name_query = { "term": { "operationName": op_name } }
    musts = eq_query.get_queries_with([serviceName_query, op_name_query])
    
    query = { "bool" : { "must": musts } }
    fields = ["startTime"] + fields
    body = {
        "query": query,
        "_source": False,
        "fields": fields,
        "size": 10000
    }
    result = client.search(index=index, body=body)
    result = [tuple([hit["fields"][key][0] for key in fields]) for hit in result.raw["hits"]["hits"]]
    result.sort(key=(lambda x:x[0]))
    return result


def plot_result(result, field_type):
    t = [datetime.fromtimestamp(r[0]/1_000_000.0) for r in result]
    if field_type:
        d = [datetime.fromisoformat(r[1]) for r in result]
    else:
        d = [(int(r[1]))/1000000 for r in result]
    plt.plot(t,d)
    plt.show()
    