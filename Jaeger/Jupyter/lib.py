from datetime import datetime
from typing import Optional, List, Dict, Any

def filter_term(term):
    return { "filter": { "term": term } }

def filter_term_op_name(op_name):
    return filter_term({ "operationName": op_name })

def filter_bool_must_terms(terms):
    return { "filter": { "bool": { "must": [{ "term": term } for term in terms] } }}

def convert_es_to_python_dateformat(format: str) -> str:
    return format.replace("MM","%m").replace("dd","%d").replace("hh","%H").replace("mm","%M").replace("ss","%S")

def add_range_to(time_from_str: Optional[str], time_to_str: Optional[str], prev: List[Dict[str,Any]]) -> List[Dict[str,Any]]:
    time_from = None
    time_to = None
    if time_from_str:
        time_from = int(datetime.strptime(time_from_str, "%Y-%m-%dT%H:%M:%S.%fZ").timestamp()*1000)
    if time_to_str:
        time_to = int(datetime.strptime(time_to_str, "%Y-%m-%dT%H:%M:%S.%fZ").timestamp()*1000)

    if time_from and time_to:
        prev.append({ "range": { "startTimeMillis": { "gte": time_from, "lte": time_to } } })
    elif time_from:
        prev.append({ "range": { "startTimeMillis": { "gte": time_from  } } })
    elif time_to:
        prev.append({ "range": { "startTimeMillis": { "lte": time_to  } } })
    return prev

class ESQuery:
    def __init__(self, namespace : str):
        self.queries = [{ "term": { "process.tag.service@namespace": namespace } }]
        pass

    def add_service_and_op_name(self, service_name: str, operation_name: str) -> "ESQuery":
        self.queries.extend([{ "term": { "process.serviceName": service_name } }, { "term": { "operationName": operation_name } }])
        return self

    def add_range(self, time_from: Optional[str], time_to: Optional[str]) -> "ESQuery":
        self.queries = add_range_to(time_from, time_to, self.queries)
        return self

    def add_query(self, query: Dict[str,Any]) -> "ESQuery":
        self.queries.append(query)
        return self

    def get_queries(self):
        return self.queries
    
    def get_queries_with(self, extras):
        return self.queries + extras
    