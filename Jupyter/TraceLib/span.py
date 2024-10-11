from typing import Dict, List

class Reference:
    def __init__(self, json_source : Dict[str,str]):
        self.ref_type : str = json_source["refType"]
        self.trace_id : str = json_source["traceID"]
        self.span_id : str = json_source["spanID"]

class Span:
    def __init__(self, json_source):
        self.json_source = json_source
        self.trace_id : str = json_source["traceID"]
        self.span_id : str = json_source["spanID"]
        self.name : str = json_source["operationName"]
        self.refs : List[Reference] = [Reference(r) for r in json_source["references"]]
        self.tags : Dict[str,str] = {t["key"] : t["value"] for t in json_source["tags"]}
        if "process" in json_source.keys():
            #print(json_source.keys())
            self.service_name : str = json_source["process"]["serviceName"]
        else:
            self.service_name : str = ""
        self.start_time : int = int(json_source["startTime"])
        self.duration : int = int(json_source["duration"])

   
    def get_bool_tag(self, key: str) -> bool:
        return bool(self.tags[key])
    
    def get_service_name(self) -> str:
        return self.service_name
    
    def get_int_tag(self, key: str) -> int:
        return int(self.tags[key])
    
    def get_str_tag(self, key: str) -> str:
        return self.tags[key]

