from frame import Frame
from typing import List

class Stats:
    def __init__(self):
        self.min = None
        self.max = None
        self.mean = None
        self.sd = None

class DigitiserStats:
    def __init__(self):
        self.duration_us : int = None
        self.start_time_us : int = None
        self.end_time_us : int = None
        self.event_kafka_time_ms : int = None
        self.aggregator_kafka_time_ms : int = None
        self.writer_kafka_time_ms : int = None

class FrameStats:
    def __init__(self):
        self.digitisers : List[DigitiserStats] = []
        
        # Stats over all digitisers
        self.duration_us : Stats = None
        self.start_time_us : Stats = None
        self.end_time_us : Stats = None
        self.event_kafka_time_ms : Stats = None
        self.aggregator_kafka_time_ms : Stats = None
        self.writer_kafka_time_ms : Stats = None
        
class FramesStats:
    def __init__(self):
        self.frames : List[Frame] = []

        # Stats over all frames
        self.duration_us : Stats = None
        pass