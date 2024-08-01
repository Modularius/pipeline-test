from typing import Dict, List, Optional
import pprint

class Reference:
    def __init__(self, json_source : Dict[str,str]):
        self.ref_type : str = json_source["refType"]
        self.trace_id : str = json_source["traceID"]
        self.span_id : str = json_source["spanID"]

class Span:
    def __init__(self, json_source, trace : 'Trace'):
        self.json_source = json_source
        self.trace : 'Trace' = trace
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

        self.parent_found = False
        self.heroes_found = False

        self.parent : Optional['Span'] = None
        self.children : List['Span'] = []
        self.heroes : List['Span'] = []

    def __str__(self) -> str:
        heroes_str = "|".join([str(c) for c in self.heroes])
        return f"[{self.name} <- ({heroes_str})] (- {str(self.parent)}"
    
    def get_bool_tag(self, key: str) -> bool:
        return bool(self.tags[key])
    
    def get_service_name(self) -> str:
        return self.service_name
    
    def get_int_tag(self, key: str) -> int:
        return int(self.tags[key])
    
    def get_str_tag(self, key: str) -> str:
        return self.tags[key]
    
    def get_child_span_sublist(self, operation : str) -> List['Span']:
        return [c for c in self.children if c.name == operation]

    def get_only_child(self, expected_name : str, expected_service : str) -> 'Span':
        children = self.get_child_span_sublist(expected_name)
        if len(children) != 1:
            pprint.pprint(self.json_source, compact=True)
            raise Exception("Not an only child", len(children), len(self.children))
        #elif children[0].service_name != expected_service:
        #    raise Exception("Unexpected service of Child")
        else:
            return children[0]

    def get_hero_span_sublist(self, operation : str) -> List['Span']:
        return [h for h in self.heroes if h.name == operation]
 
    def get_only_hero(self, expected_name : str, expected_service : str) -> 'Span':
        heroes = self.get_hero_span_sublist(expected_name)
        if len(heroes) != 1:
            pprint.pprint(self.json_source, compact=True)
            raise Exception("Not an only hero", len(heroes), len(self.heroes), expected_name)
        #elif heroes[0].service_name != expected_service:
        #    raise Exception("Unexpected service of Hero")
        else:
            return heroes[0]
        
    def get_parent(self, expected_name : str, expected_service : str) -> 'Span':
        if self.parent:
            if self.parent.name != expected_name:
                pprint.pprint(self.json_source, compact=True)
                pprint.pprint(self.parent.json_source, compact=True)
                raise Exception("Unexpected parent name:", self.parent.name, expected_name)
            #elif self.parent.service_name != expected_service:
            #    raise Exception("Unexpected parent service:", self.parent.service_name)
            return self.parent
        pprint.pprint(self.json_source, compact=True)
        raise Exception("No parent")

    def extract_parent_from_traces(self, source : 'TraceBank'):
        if self.parent_found:
            return
        
        parent_ref = next((r for r in self.refs if r.ref_type == "CHILD_OF"), None)
        if parent_ref:
            if parent_ref.trace_id in source.traces:
                if parent_ref.span_id in source.traces[parent_ref.trace_id].spans:
                    self.parent = source.traces[parent_ref.trace_id].spans[parent_ref.span_id]
                    self.parent.children.append(self)
                    self.parent_found = True

    def extract_heroes_from_traces(self, source : 'TraceBank'):
        for r in [r for r in self.refs if r.ref_type == "FOLLOWS_FROM"]:
            if r.trace_id in source.traces:
                if r.span_id in source.traces[r.trace_id].spans:
                    if source.traces[r.trace_id].spans[r.span_id] not in self.heroes:
                        self.heroes.append(source.traces[r.trace_id].spans[r.span_id])
                else:
                    pprint.pprint(self.json_source, compact=True)
                    raise Exception("Hero span not found in trace")
            else:
                pprint.pprint(self.json_source, compact=True)
                raise Exception("Hero trace not found")





class Trace:
    def __init__(self, json_source, bank : 'TraceBank'):
        self.bank : 'TraceBank' = bank
        self.trace_id : str = json_source["traceID"]
        self.spans : Dict[str, Span] = {span["spanID"]: Span(span, self) for span in json_source["spans"]}

    def __str__(self) -> str:
        span_str = "\n".join([f"    {s}: {str(self.spans[s])}" for s in self.spans]) 
        return f"{span_str}"

    def validate(self) -> bool:
        for s in self.spans.values():
            if self.trace_id != s.trace_id:
                return False
        return True

    def extract_parents_from_traces(self, source : 'TraceBank'):
        for s in self.spans:
            self.spans[s].extract_parent_from_traces(source)


    def extract_heroes_from_traces(self, source : 'TraceBank'):
        for s in self.spans.values():
            s.extract_heroes_from_traces(source)
    
    def get_span_subset(self, operation : str) -> Dict[str, Span]:
        return {k:v for (k,v) in self.spans.items() if v.name == operation}



class TraceBank:
    def __init__(self, json_source):
        self.traces : Dict[str,Trace] = {t["traceID"] : Trace(t, self) for t in json_source}
    
    def union(self, other : 'TraceBank'):
        self.traces.update(other.traces)

    def __str__(self) -> str:
        trace_str = "\n".join([f"  {t}\n{str(self.traces[t])}" for t in self.traces]) 
        return f"TraceBank\n{trace_str}"

    def extract_spans(self) -> Dict[str,Span]:
        return {k:v for t in self.traces.values() for (k,v) in t.spans.items()}

    def extract_parents_from_traces(self, source : 'TraceBank'):
        for t in self.traces:
            self.traces[t].extract_parents_from_traces(source)

    def extract_heroes_from_traces(self, source : 'TraceBank'):
        for t in self.traces.values():
            t.extract_heroes_from_traces(source)