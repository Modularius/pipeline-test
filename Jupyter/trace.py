from typing import Dict, List, Optional

class Reference:
    def __init__(self, json_source : Dict[str,str]):
        self.ref_type : str = json_source["refType"]
        self.trace_id : str = json_source["traceID"]
        self.span_id : str = json_source["spanID"]

class Span:
    def __init__(self, json_source, trace : 'Trace'):
        self.trace = trace
        self.trace_id : str = json_source["traceID"]
        self.span_id : str = json_source["spanID"]
        self.name : str = json_source["operationName"]
        self.refs = [Reference(r) for r in json_source["references"]]
        self.tags : Dict[str,str] = {t["key"] : t["value"] for t in json_source["tags"]}
        self.start_time = int(json_source["startTime"])
        self.duration = int(json_source["duration"])

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
    
    def get_int_tag(self, key: str) -> int:
        return int(self.tags[key])
    
    def get_str_tag(self, key: str) -> str:
        return self.tags[key]
    
    def get_child_span_sublist(self, operation : str) -> List['Span']:
        return [c for c in self.children if c.name == operation]

    def get_only_child(self, expected_name : str) -> Optional['Span']:
        children = self.get_child_span_sublist(expected_name)
        if len(children) != 1:
            print("Not an only child", len(children))
            print("parent:", self)
            if len(children) == 0:
                for c in self.children:
                    print("All Children:", c)
            else:
                for c in children:
                    print(c)
            print("")
        else:
            return children[0]

    def get_hero_span_sublist(self, operation : str) -> List['Span']:
        return [h for h in self.heroes if h.name == operation]
 
    def get_only_hero(self, expected_name : str) -> Optional['Span']:
        heroes = self.get_hero_span_sublist(expected_name)
        if len(heroes) != 1:
            print("Not an only hero", len(heroes))
            print("parent:", self)
            if len(heroes) == 0:
                for h in self.heroes:
                    print("All Heroes:", h)
            else:
                for h in heroes:
                    print(h)
            print("")
        else:
            return heroes[0]
        
    def get_parent(self, expected_name : str) -> Optional['Span']:
        if self.parent and self.parent.name == expected_name:
            return self.parent

    def find_parent_from_traces(self, source : 'TraceBank'):
        if self.parent_found:
            return
        
        parent_ref = next((r for r in self.refs if r.ref_type == "CHILD_OF"), None)
        if parent_ref:
            if parent_ref.trace_id in source.traces:
                if parent_ref.span_id in source.traces[parent_ref.trace_id].spans:
                    self.parent = source.traces[parent_ref.trace_id].spans[parent_ref.span_id]
                    self.parent.children.append(self)
                    self.parent_found = True

    def find_heroes(self, source : 'TraceBank'):
        for r in [r for r in self.refs if r.ref_type == "FOLLOWS_FROM"]:
            if r.trace_id in source.traces:
                if r.span_id in source.traces[r.trace_id].spans:
                    self.heroes.append(source.traces[r.trace_id].spans[r.span_id])

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

    def find_parents_from_traces(self, source : 'TraceBank'):
        for s in self.spans:
            self.spans[s].find_parent_from_traces(source)


    def find_heroes(self, source : 'TraceBank'):
        for s in self.spans.values():
            s.find_heroes(source)
    
    def get_span_subset(self, operation : str) -> Dict[str, Span]:
        return {k:v for (k,v) in self.spans.items() if v.name == operation}

class TraceBank:
    def __init__(self, json_source):
        self.traces : Dict[str,Trace] = {t["traceID"] : Trace(t, self) for t in json_source}

    def __str__(self) -> str:
        trace_str = "\n".join([f"  {t}\n{str(self.traces[t])}" for t in self.traces]) 
        return f"TraceBank\n{trace_str}"

    def extract_spans(self) -> Dict[str,Span]:
        return {k:v for t in self.traces.values() for (k,v) in t.spans.items()}

    def find_parents_from_traces(self, source : 'TraceBank'):
        for t in self.traces:
            self.traces[t].find_parents_from_traces(source)

    def find_heroes(self, source : 'TraceBank'):
        for t in self.traces.values():
            t.find_heroes(source)