from confluent_kafka import Producer, Consumer, ConsumerGroupTopicPartitions, TopicPartition
from confluent_kafka.admin import AdminClient
import asyncio
import socket

conf = {
    'bootstrap.servers': '130.246.55.29:9092',
    'group.id': 'Copier'
}
admin = AdminClient(conf)

consumer = Consumer(conf)
producer = Producer(conf)
consumer.subscribe(["daq-traces-in"])

def acked(err, msg):
    if err is not None:
        print("Failed to deliver message: %s: %s" % (str(msg), str(err)))
    else:
        pass #print("Message produced: %s" % (str(msg)))

num = 1113607
for n in range(0,1113607):
    msg = consumer.poll(timeout=1.0)
    if msg:
        producer.produce("daq-traces-in-test", key = "Resent", value = msg.value(), callback=acked)
        if n % 1000 == 999:
            print(f"Flushing message {n}")
            producer.flush()
    else:
        pass
producer.flush()
consumer.close()

#for message in consumer:
#    order = message.value
#    print()