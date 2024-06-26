from typing import Dict, List
from trace import Trace, Span

class Digitiser:
    def __init__(self, digitiser : Span):
        self.agg_span = digitiser
        self.evt_span = digitiser.follow_froms[0]
        self.channel = [s for s in self.evt_span.children]

class Frame:
    def __init__(self, frame : Span, digitiser_el_spans : List[Span]):
        self.run_span = frame
        self.agg_span = frame.follow_froms[0]
        self.digitisers = [Digitiser(s) for s in self.agg_span.children]

class Run:
    def __init__(self, run : Span, frame_el_spans : List[Span]):
        self.span = run
        self.frames = [Frame(s) for s in self.span.children]
    
    def print(self):
        print("New Run")
        for f in self.frames:
            print(f)