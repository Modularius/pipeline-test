from typing import Optional
from frame.frame_assembler import FrameAssembler

class ProcessKafkaMessageInEventFormation:
    def __init__(self, source):
        self.doc = source

    def print_hierarchy(self, prefix = ""):
        print(prefix, "Process Kafka Message")
        if "kafka_message_timestamp_ms" in self.doc["tag"]:
            print(prefix, "-<" f"kafka_timestamp_ms = {self.doc["tag"]["kafka_message_timestamp_ms"]}")

    def is_complete(self):
        return "kafka_message_timestamp_ms" in self.doc["tag"]

    def get_event_kafka_time(self) -> Optional[int]:
        if "kafka_message_timestamp_ms" in self.doc["tag"]:
            return self.doc["tag"]["kafka_message_timestamp_ms"]

    def get_start_time(self) -> Optional[int]:
        if "startTime" in self.doc:
            return self.doc["startTime"]

class ProcessDigitiserTraceMessage:
    def __init__(self, source, assembler: FrameAssembler):
        self.doc = source
        element = next((element for element in assembler.process_kafka_messages_events if element["spanID"] == self.doc["parentSpanID"]), None)
        if element:
            self.process_kafka_message = ProcessKafkaMessageInEventFormation(element)
        else:
            self.process_kafka_message = None
        
        element = next((element for element in assembler.process_events if element["parentSpanID"] is self.doc["spanID"]), None)
        if element:
            self.process = ProcessInEventFormation(element)
        else:
            self.process = None

    def is_complete(self):
        if self.process_kafka_message is None or not self.process_kafka_message.is_complete():
            return False
        
        return self.process and self.process.is_complete()
    
    def print_hierarchy(self, prefix = ""):
        print(prefix, "Process Digitiser Trace Message")
        if self.process:
            self.process.print_hierarchy(prefix + "\\--")
        if self.process_kafka_message:
            self.process_kafka_message.print_hierarchy(prefix + "|--")

    def get_start_time(self) -> Optional[int]:
        if self.process_kafka_message:
            return self.process_kafka_message.get_start_time()

    def get_event_kafka_time(self) -> Optional[int]:
        if self.process_kafka_message:
            return self.process_kafka_message.get_event_kafka_time()


class ProcessInEventFormation:
    def __init__(self, source):
        self.doc = source

    def is_complete(self):
        return "num_total_pulses" in self.doc["tag"]
    
    def print_hierarchy(self, prefix = ""):
        print(prefix, "Process")
        if "num_total_pulses" in self.doc["tag"]:
            print(prefix, "-<" f"num_pulses = {self.doc["tag"]["num_total_pulses"]}")


class ProcessKafkaMessageInAggregator:
    def __init__(self, source, assembler: FrameAssembler):
        self.doc = source
        element = next((element for element in assembler.process_digitiser_trace_messages if element["spanID"] == self.doc["parentSpanID"]), None)
        if element:
            self.process_digitiser_trace_message = ProcessDigitiserTraceMessage(element, assembler)
        else:
            self.process_digitiser_trace_message = None

    def is_complete(self):
        if self.process_digitiser_trace_message is None or not self.process_digitiser_trace_message.is_complete():
            return False
        return "kafka_message_timestamp_ms" in self.doc["tag"]
    
    def print_hierarchy(self, prefix = ""):
        print(prefix, "Process Kafka Message")
        if "kafka_message_timestamp_ms" in self.doc["tag"]:
            print(prefix, "-<" f"kafka_timestamp_ms = {self.doc["tag"]["kafka_message_timestamp_ms"]}")
        if self.process_digitiser_trace_message:
            self.process_digitiser_trace_message.print_hierarchy(prefix + "|--")
        else:
            self.process_digitiser_trace_message = None

    def get_start_time(self) -> Optional[int]:
        if self.process_digitiser_trace_message:
            return self.process_digitiser_trace_message.get_start_time()

    def get_aggregator_kafka_time(self) -> Optional[int]:
        if "kafka_message_timestamp_ms" in self.doc["tag"]:
            return self.doc["tag"]["kafka_message_timestamp_ms"]

    def get_event_kafka_time(self) -> Optional[int]:
        if self.process_digitiser_trace_message:
            return self.process_digitiser_trace_message.get_event_kafka_time()

class ProcessDigitiserEventListMessage:
    def __init__(self, source, assembler: FrameAssembler):
        self.doc = source
        element = next((element for element in assembler.process_kafka_messages_aggregator if element["spanID"] == self.doc["parentSpanID"]), None)
        if element:
            self.process_kafka_message = ProcessKafkaMessageInAggregator(element, assembler)
        else:
            self.process_kafka_message = None

    def print_hierarchy(self, prefix = ""):
        print(prefix, "Process Digitiser Event List Message")
        if "digitiser_id" in self.doc["tag"]:
            print(prefix, "-<" f"digitiser_id = {self.doc["tag"]["digitiser_id"]}")
        if self.process_kafka_message:
            self.process_kafka_message.print_hierarchy(prefix + "|--")
    
    def get_aggregator_kafka_time(self) -> Optional[int]:
        if self.process_kafka_message:
            return self.process_kafka_message.get_aggregator_kafka_time()
        
    def get_event_kafka_time(self) -> Optional[int]:
        if self.process_kafka_message:
            return self.process_kafka_message.get_event_kafka_time()

    def get_start_time(self) -> Optional[int]:
        if self.process_kafka_message:
            return self.process_kafka_message.get_start_time()

class DigitiserEventList:
    def __init__(self, source, assembler: FrameAssembler):
        self.doc = source
        follows_from_id = next(ref["spanID"] for ref in self.doc["references"] if ref["refType"] == "FOLLOWS_FROM")
        element = next((element for element in assembler.process_digitiser_event_list_messages if element["spanID"] == follows_from_id), None)
        if element:
            self.process_digitiser_event_list_message = ProcessDigitiserEventListMessage(element, assembler)
        else:
            self.process_digitiser_event_list_message = None
    
    def get_aggregator_kafka_time(self) -> Optional[int]:
        if self.process_digitiser_event_list_message:
            return self.process_digitiser_event_list_message.get_aggregator_kafka_time()
        
    def get_event_kafka_time(self) -> Optional[int]:
        if self.process_digitiser_event_list_message:
            return self.process_digitiser_event_list_message.get_event_kafka_time()

    def get_start_time(self) -> Optional[int]:
        if self.process_digitiser_event_list_message:
            return self.process_digitiser_event_list_message.get_start_time()

    def populate_stats(self):
        self.duration_us = None
        self.start_time_us = None
        self.end_time_us = None
        self.event_kafka_time_ms = None
        self.aggregator_kafka_time_ms = None
        self.kafka_delay_ms = None
        
        self.start_time_us = self.get_start_time()
        self.end_time_us = self.doc["startTime"] + self.doc["duration"]
        self.event_kafka_time_ms = self.get_event_kafka_time()
        self.aggregator_kafka_time_ms = self.get_aggregator_kafka_time()
        if self.start_time_us:
            self.duration_us = self.end_time_us - self.start_time_us
        if self.event_kafka_time_ms and self.aggregator_kafka_time_ms:
            self.kafka_delay_ms = self.aggregator_kafka_time_ms - self.event_kafka_time_ms
            self.total_estimated_pipeline_time_us = self.end_time_us - self.event_kafka_time_ms*1000

    def print_stats(self, prefix = ""):
        print(prefix, "Digitiser Event List")
        if self.duration_us:
            print(prefix, "Duration:", self.duration_us, "us")
        if self.kafka_delay_ms:
            print(prefix, "Kafka Delay:", self.kafka_delay_ms, "ms")
        if self.total_estimated_pipeline_time_us:
            print(prefix, "Total Estimated Pipeline Time:", self.total_estimated_pipeline_time_us, "us")

    def print_hierarchy(self, prefix = ""):
        print(prefix, "Digitiser Event List")
        if self.process_digitiser_event_list_message:
            self.process_digitiser_event_list_message.print_hierarchy(prefix + "|--")

class Frame:
    def __init__(self, source, assembler: FrameAssembler):
        self.doc = source
        self.elements = [element for element in assembler.digitiser_event_lists if element["parentSpanID"] == self.doc["spanID"]]
        self.DigitiserEventLists = [DigitiserEventList(element, assembler) for element in self.elements]
        self.process_kafka_messages_doc = next(element for element in assembler.process_kafka_messages_writer if element["parentSpanID"] == self.doc["spanID"])
        
    def print_stats(self):
        for d in self.DigitiserEventLists:
            d.populate_stats()
            d.print_stats("|--")
            
        self.start_time_us = min(d.start_time_us for d in self.DigitiserEventLists)
        self.end_time_us = self.doc["startTime"] + self.doc["duration"]
        if self.start_time_us:
            self.duration_us = self.end_time_us - self.start_time_us
            print("Duration:", self.duration_us, "us")
        self.event_kafka_time_ms = min(d.event_kafka_time_ms for d in self.DigitiserEventLists)
        if self.event_kafka_time_ms:
            self.total_estimated_pipeline_time_us = self.end_time_us - self.event_kafka_time_ms*1000
            print("Total Estimated Pipeline Time:", self.total_estimated_pipeline_time_us, "us")


        self.av_duration_us = sum(d.duration_us for d in self.DigitiserEventLists)/len(self.DigitiserEventLists)
        self.av_kafka_delay_ms = sum(d.kafka_delay_ms for d in self.DigitiserEventLists)/len(self.DigitiserEventLists)
        self.av_total_estimated_pipeline_time_us = sum(d.total_estimated_pipeline_time_us for d in self.DigitiserEventLists)/len(self.DigitiserEventLists)
        print("Average Digitiser Duration:", self.av_duration_us, "us")
        print("Average Digitiser Kafka Delay:", self.av_kafka_delay_ms, "ms")
        print("Average Digitiser Total Estimated Pipeline Time:", self.av_total_estimated_pipeline_time_us, "us")

    def print_hierarchy(self, prefix = ""):
        print(prefix, "Frame")
        if "kafka_message_timestamp_ms" in self.process_kafka_messages_doc["tag"]:
            print(prefix, "-<" f"kafka_timestamp_ms = {self.process_kafka_messages_doc["tag"]["kafka_message_timestamp_ms"]}")
        
        print(prefix, "-<" f"metadata_timestamp = {self.doc["tag"]["metadata_timestamp"]}")
        for digitiser_event_list in self.DigitiserEventLists:
            digitiser_event_list.print_hierarchy(prefix + "|--")