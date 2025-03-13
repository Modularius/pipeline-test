from elasticsearch import Elasticsearch
import json
from typing import List, Dict, Any, Optional

type Doc = Dict[str,Any]
type Docs = List[Doc]

class esSearcher:
    def __init__(self, client, namespace: str, index_filter : str = "", size: int = 10000):
        self.namespace = namespace
        self.client = client
        self.size = size
        self.index = "jaeger-span-" + index_filter + "*"

    def do_bool_search(self, index : str, size : int, musts : Docs, shoulds : Docs = [], filters : Docs = [], must_nots: Docs = [], time_from: Optional[str] = None, time_to: Optional[str] = None) -> Docs:
        filters.append({ "term": { "process.tag.service@namespace": self.namespace } })
        query = {
            "bool" : {
                "filter": filters,
                "must": musts,
                "should": shoulds,
                "must_not": must_nots
            }
        }
        return self.client.search(index=index, query=query, size=size, source=False, timeout=None)["hits"]["hits"]

    def find_documents(self, ids : List[str], time_from: Optional[str] = None, time_to: Optional[str] = None) -> Docs:
        query = {
            "ids": { "values": ids }
        }
        results = self.client.search(index=self.index, query=query, size=self.size, timeout=None)["hits"]["hits"]
        return [result["_source"] for result in results]

    def find_children(self, docs : Docs, operationName : str) -> Docs:
        musts = [
            { "term": { "operationName": operationName } },
            { "terms": { "parentSpanID": [doc["spanID"] for doc in docs] } }
        ]
        return self.do_bool_search(self.index, self.size, musts)

    def find_parents(self, docs : Docs, operationName : str) -> Docs:
        for doc in docs:
            if "parentSpanID" not in doc:
                print(doc)
        musts = [
            { "term": { "operationName": operationName } },
            { "terms": { "spanID": [doc["parentSpanID"] for doc in docs] } }
        ]
        return self.do_bool_search(self.index, self.size, musts)

    def find_follows_froms(self, docs : Docs, operationName : str) -> Docs:
        refSpanIDs = [next(ref["spanID"] for ref in doc["references"] if ref["refType"] == "FOLLOWS_FROM") for doc in docs]
        musts = [
            { "term": { "operationName": operationName } },
            { "terms": { "spanID": refSpanIDs } }
        ]
        return self.do_bool_search(self.index, self.size, musts)


class FrameAssembler(esSearcher):
    def __init__(self, client, namespace: str, index_filter : str = "", size: int = 10000):
        esSearcher.__init__(self, client, namespace, index_filter, size)

    def find_missing_process_digitiser_event_list_message(self, frames : Docs, existing_docs: List[str]) -> Docs:
        metadata_timestamps = [frame["tag"]["metadata_timestamp"] for frame in frames]
        musts = [
            { "term": { "operationName": "process_digitiser_event_list_message" } },
            { "terms": { "tag.metadata_timestamp": metadata_timestamps } }
        ]
        must_nots = [{ "ids": { "values": existing_docs } }]
        return self.do_bool_search(index=self.index, size=self.size, musts=musts, shoulds=[], filters=[], must_nots=must_nots)


    def find_frames(self, musts : Docs, shoulds : Docs = [], filters : Docs = [], index_filter: str = "", size: int = 10000):
        filters.append({ "term": { "operationName": "Frame" } })
        index = "jaeger-span-" + index_filter +  "*"
        id_docs = self.do_bool_search(index, size, musts,shoulds,filters)

        ids = [doc["_id"] for doc in id_docs]
        self.frames = self.find_documents(ids)
        
        print("Finding Digitiser Event List")
        id_docs = self.find_children(self.frames, "Digitiser Event List")
        ids = [doc["_id"] for doc in id_docs]
        self.digitiser_event_lists = self.find_documents(ids)

        print("Finding process_digitiser_event_list_message")
        id_docs = self.find_follows_froms(self.digitiser_event_lists, "process_digitiser_event_list_message")
        ids = [doc["_id"] for doc in id_docs]
        self.process_digitiser_event_list_messages = self.find_documents(ids)

        extra_id_docs = self.find_missing_process_digitiser_event_list_message(self.frames, ids)
        ids = [doc["_id"] for doc in extra_id_docs]
        self.missing_process_digitiser_event_list_messages = self.find_documents(ids)

        print("Finding process_kafka_message (digitiser-aggregator)")
        id_docs = self.find_parents(self.process_digitiser_event_list_messages, "process_kafka_message")
        ids = [doc["_id"] for doc in id_docs]
        self.process_kafka_messages_aggregator = self.find_documents(ids)

        print("Finding process_digitiser_trace_message")
        id_docs = self.find_parents(self.process_kafka_messages_aggregator, "process_digitiser_trace_message")
        ids = [doc["_id"] for doc in id_docs]
        self.process_digitiser_trace_messages = self.find_documents(ids)

        print("Finding process_kafka_message (trace-to-events)")
        id_docs = self.find_parents(self.process_digitiser_trace_messages, "process_kafka_message")
        ids = [doc["_id"] for doc in id_docs]
        self.process_kafka_messages_events = self.find_documents(ids)

        print("Finding process")
        id_docs = self.find_children(self.process_digitiser_trace_messages, "process")
        ids = [doc["_id"] for doc in id_docs]
        self.process_events = self.find_documents(ids)

        print("Finding process_kafka_message (nexus-writer)")
        id_docs = self.find_children(self.frames, "process_kafka_message")
        ids = [doc["_id"] for doc in id_docs]
        self.process_kafka_messages_writer = self.find_documents(ids)

    def print_summary(self):
        print(f"{len(self.frames)} frames")
        print(f"{len(self.process_kafka_messages_writer)} process_kafka_messages_writer")
        print(f"{len(self.process_digitiser_event_list_messages)} process_digitiser_event_list_messages")
        print(f"{len(self.process_kafka_messages_aggregator)} process_kafka_messages_aggregator")
        print(f"{len(self.process_digitiser_trace_messages)} process_digitiser_trace_messages")
        print(f"{len(self.process_kafka_messages_events)} process_kafka_messages_events")
        print(f"{len(self.process_events)} process_events")