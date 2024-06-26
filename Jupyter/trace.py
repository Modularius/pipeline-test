from typing import Dict, List

class Reference:
    def __init__(self, src : Dict[str, object]):
        self.ref_type = src["refType"]
        self.trace_id = src["traceID"]
        self.span_id = src["spanID"]

class Span:
    def __init__(self, src : Dict[str, object]):
        self.trace_id = src["traceID"]
        self.span_id = src["spanID"]
        self.name = src["operationName"]
        self.refs = [Reference(r) for r in src["references"]]
        self.start_time = int(src["startTime"])
        self.duration = int(src["duration"])

        self.children = []
        self.follow_froms = []

    def __str__(self):
        return f"{self.trace_id}, {self.span_id}, {self.name}"

    def find_parent(self, source):
        parent_ref = next((r for r in self.refs if r.ref_type == "CHILD_OF"), None)
        if parent_ref:
            parents = [p for p in source if p.span_id == parent_ref.span_id]
            if len(parents) == 1:
                parents[0].children.append(self)
            else:
                print("parental dispute", parents)

    def find_followed_froms(self, source):
        follows_from_ref = [r for r in self.refs if r.ref_type == "FOLLOWS_FROM"]

        for ref_f in follows_from_ref:
            followed = [f for f in source if f.span_id == ref_f.span_id]
            if len(followed) == 1:
                self.follow_froms.append(followed[0])
            else:
                print("follow dispute", followed)

class Trace:
    def __init__(self, src):
        self.trace_id = src["traceID"]
        self.spans = [Span(span) for span in src["spans"]]
        self.processes = src["processes"]
        self.warnings = src["warnings"]
        self.roots = []

    def __str__(self):
        span_str = "\n".join([str(s) for s in self.spans]) 
        return f"{self.trace_id}\n{span_str}"

    def validate(self):
        for s in self.spans:
            if self.trace_id != s.trace_id:
                return False
            if set(s.child_ids) != {c.span_id for c in s.children}:
                return False
        return True

    def find_children(self):
        for s in self.spans:
            s.find_parent(self.spans)

    def find_followed_froms(self, source):
        source = [x for y in source for x in y.spans]
        for s in self.spans:
            s.find_followed_froms(source)
    
    def duration_of(self, operation):
        return [s.duration for s in self.spans if s.name == operation]
