from typing import Optional, List, Tuple, Any
from frame.frame_assembler import FrameAssembler, Doc, Docs
import json

def doc_to_json(doc: Doc) -> str:
    return json.dumps(doc, indent=4)

def get_one_doc_with_key_equal_to(source : Docs, key : str, value : str) -> Optional[Doc]:
     return next((element for element in source if element[key] == value), None)

def get_docs_with_key_equal_to(source : Docs, key : str, value : str) -> Docs:
     return [element for element in source if element[key] == value]

class Span:
    def __init__(self, doc : Doc):
        self.doc : Doc = doc

        self.tag = doc["tag"]
        
        self.start = doc["startTime"]
        self.duration = doc["duration"]
    
        self.end = self.start + self.duration


    def __getitem__(self, key) -> Optional[Any]:
        return self.doc.get(key)
    
    def get_parent_doc_from(self, source: Docs) -> Doc:
        doc = get_one_doc_with_key_equal_to(source, "spanID", self.doc["parentSpanID"])
        if doc:
            return doc
        else:
            raise Exception(f"Cannot find parent doc in source.")
    
    def get_one_child_doc_from(self, source: Docs) -> Doc:
        doc = get_one_doc_with_key_equal_to(source, "parentSpanID", self.doc["spanID"])
        if doc:
            return doc
        else:
            raise Exception(f"Cannot find child doc in source.")

    def get_one_follows_from_doc_from(self, source: Docs) -> Doc:
        follows_from_id = next((
            ref["spanID"] for ref in self.doc["references"]
                if ref["refType"] == "FOLLOWS_FROM"
        ), None)

        if follows_from_id:
            doc = get_one_doc_with_key_equal_to(source, "spanID", follows_from_id)
        else:
            doc = None

        if doc:
            return doc
        else:
            raise Exception(f"Cannot find follows from doc in source.")

    def get_child_docs_from(self, source: Docs) -> Docs:
        return get_docs_with_key_equal_to(source, "parentSpanID", self.doc["spanID"])
    
    def print_summary(self, prefix = ""):
        opName = self.doc["operationName"]
        print(prefix, f"Span {opName}")

class Metadata:
    def __init__(self, tag : Doc):
        self.timestamp : Optional[str] = tag.get("metadata_timestamp")
        self.frame_number : Optional[int] = tag.get("metadata_frame_number")

        if self.timestamp is None:
            raise Exception(f"timestamp is None: {doc_to_json(tag)}")
        if self.frame_number is None:
            raise Exception(f"frame_number is None: {doc_to_json(tag)}")

    def is_timestamp_equal(self, doc : Doc) -> bool:
        tag = doc.get("tag")
        if tag is None:
            raise Exception("Tag is None")
        timestamp = tag.get("metadata_timestamp")
        if timestamp:
            return self.timestamp == timestamp
        else:
            raise Exception("Timestamp")

class Digitiser:
    def __init__(self, doc : Doc, assembler: FrameAssembler):
        ### Aggregator Spans
        self.process_digitiser_event_list_message : Span = Span(doc)
        self.aggregator_process_kafka_message : Optional[Span] = None
        ### Event Formation Spans
        self.process_digitiser_trace_message : Optional[Span] = None
        self.event_formation_process_kafka_message : Optional[Span] = None
        self.event_formation_process : Optional[Span] = None

        ### aggregator process_kafka_message
        self.aggregator_process_kafka_message = Span(
            self.process_digitiser_event_list_message.get_parent_doc_from(assembler.process_kafka_messages_aggregator)
        )

        ### process_digitiser_trace_message
        if self.aggregator_process_kafka_message:
            self.process_digitiser_trace_message = Span(
                self.aggregator_process_kafka_message.get_parent_doc_from(assembler.process_digitiser_trace_messages)
            )

        ### event_formation process_kafka_message and process
        if self.process_digitiser_trace_message:
            self.event_formation_process_kafka_message = Span(
                self.process_digitiser_trace_message.get_parent_doc_from(assembler.process_kafka_messages_events)
            )
            self.event_formation_process = Span(
                self.process_digitiser_trace_message.get_one_child_doc_from(assembler.process_events)
            )

        self.metadata = Metadata(self.process_digitiser_event_list_message.tag)
        self.digitiser_id = self.process_digitiser_event_list_message.tag.get("digitiser_id")
        
    def get_span_durations(self) -> Optional[Tuple[int,int,int]]:
        if self.event_formation_process_kafka_message is None:
            return None
        
        if self.aggregator_process_kafka_message is None:
            return None

        # trace_kafka_timestamp -> aggregator_kafka_timestamp
        # process_digitiser_trace_message -> process_digitiser_event_list_message
        #     process
        trace_duration = self.event_formation_process_kafka_message.duration
        time_between = self.aggregator_process_kafka_message.start \
            - self.event_formation_process_kafka_message.end
        eventlist_duration = self.aggregator_process_kafka_message.duration
        
        return (trace_duration, time_between, eventlist_duration)
        
    def get_kafka_timestamps(self) -> Optional[Tuple[int,int]]:
        if self.aggregator_process_kafka_message is None:
            return None
        
        if self.event_formation_process_kafka_message is None:
            return None
        
        aggregator_kafka_timestamp_ms = \
            self.aggregator_process_kafka_message.tag.get("kafka_message_timestamp_ms")
        event_formation_kafka_timestamp_ms = \
            self.event_formation_process_kafka_message.tag.get("kafka_message_timestamp_ms")
        
        return (aggregator_kafka_timestamp_ms, event_formation_kafka_timestamp_ms)

    def get_aggregator_cache_size(self) -> Optional[Tuple[int]]:
        if self.aggregator_process_kafka_message is None:
            return None
        
        return self.aggregator_process_kafka_message.tag.get("num_cached_frames")

    def get_num_pulses(self) -> Optional[Tuple[int,int]]:
        if self.event_formation_process is None:
            return None
        
        return self.event_formation_process.tag.get("num_total_pulses")
    
    def print_summary(self, prefix = ""):
        if self.process_digitiser_event_list_message:
            self.process_digitiser_event_list_message.print_summary(prefix + "  ")
        
        if self.aggregator_process_kafka_message:
            self.aggregator_process_kafka_message.print_summary(prefix + "    ")
        
        if self.process_digitiser_trace_message:
            self.process_digitiser_trace_message.print_summary(prefix + "      ")

        if self.event_formation_process_kafka_message:
            self.event_formation_process_kafka_message.print_summary(prefix + "        ")


class Aggragator_DigitiserEventList:
    def __init__(self, doc : Doc, assembler: FrameAssembler):
        self.span : Span = Span(doc)
        self.metadata = Metadata(self.span.tag)
        self.digitiser_id = self.span.tag.get("digitiser_id")

        assert(self.span["operationName"] == "Digitiser Event List")

        ### process_digitiser_event_list_message
        try:
            element = self.span.get_one_follows_from_doc_from(assembler.process_digitiser_event_list_messages)
            self.digitiser = Digitiser(element, assembler)
        except:
            self.digitiser = None
    
    def validate(self):
        pass

class Aggragator_Frame:
    def __init__(self, doc : Doc, assembler: FrameAssembler):
        self.span = Span(doc)
        self.metadata = Metadata(self.span.tag)
        assert(self.span["operationName"] == "Frame")

        elements = self.span.get_child_docs_from(assembler.digitiser_event_lists)
        self.NexusWriter_DigitiserEventLists = [Aggragator_DigitiserEventList(element, assembler) for element in elements]
        self.NexusWriter_process_kafka_message = Span(
            self.span.get_one_child_doc_from(assembler.process_kafka_messages_writer)
        )

        existing_digitiser_span_ids = [
            d.digitiser.process_digitiser_event_list_message["spanID"] for d in self.NexusWriter_DigitiserEventLists if d.digitiser
        ]
        self.missing_Aggregator_Digitisers = []
        '''[
            Digitiser(element, assembler) for element in assembler.missing_process_digitiser_event_list_messages
            if self.metadata.is_timestamp_equal(element)
                and element["spanID"] not in existing_digitiser_span_ids
        ]'''

        self.kafka_timestamp_ms = self.NexusWriter_process_kafka_message.tag.get("kafka_message_timestamp_ms")
        
    def validate(self):
        pass
        
    def get_stats(self):
        pass
    
    def print_summaries(self):
        print(f"Frame with {len(self.NexusWriter_DigitiserEventLists)} child digitisers, and {len(self.missing_Aggregator_Digitisers)} missing ones.")
        if self.NexusWriter_process_kafka_message:
            self.NexusWriter_process_kafka_message.print_summary()
        print("Child Digitisers")
        for d in self.NexusWriter_DigitiserEventLists:
            d.span.print_summary("")
            d.digitiser.print_summary("  ")

        print("Missing Digitisers")
        for d in self.missing_Aggregator_Digitisers:
            d.print_summary("")
        pass