# SuperMuSR Data Pipeline Deployment Test Suite

## List of Tests

### Sanity Check

These "sanity checking" tests use 8 digitisers with 8 channels each.

|Test|Runs|Frames per Run|Pulses per Trace|
|---|---|---|---|
|1|1|100|1|
|2|1|100|100|
|3|1|100000|1|
|4|1|100000|100|
|5|5|100|1|
|6|5|100|100|
|7|5|100000|1|
|8|5|100000|100|

### Missing Run Commands

These tests examine behaviour with corrupted runstart/runstop messages.

Each test is conducted with values

|Frames per Run|Pulses per Trace|
|---|---|
|100|1|
|100|100|
|100000|1|
|100000|100|

|Test|Command 1|Command 2|Command 3|Command 4|Command 5|Command 6|Expected Result|
|---|---|---|---|---|---|---|---|
|9 |Start|Stop|Start|Stop|Start|Stop|Three well-formed runs|
|10|Start|Stop|Start|Stop|Start|Start|Two well-formed run, one aborted run, and one timed-out run|
|11|Start|Stop|Start|Start|Start|Stop|One well-formed run, two aborted runs, and one well-formed run|
|12|Start|Stop|Start|Start|Stop|Stop|One well-formed run, one aborted run, one well-formed run, and one errant stop message|

### Incomplete Frames

These test examine behaviour with incomplete frames

|Test|Command 1|Command 2|Command 3|Command 4|Command 5|Command 6|Expected Result|
|---|---|---|---|---|---|---|---|
|13|Start|50 eight-digitiser frames|50 seven-digitiser frames|50 eight-digitiser frames|Stop| |Three well-formed runs|
|14|Start|Stop|Start|Stop|Start|Start|Two well-formed run, one aborted run, and one timed-out run|
|15|Start|Stop|Start|Start|Start|Stop|One well-formed run, two aborted runs, and one well-formed run|
|16|Start|Stop|Start|Start|Stop|Stop|One well-formed run, one aborted run, one well-formed run, and one errant stop message|
