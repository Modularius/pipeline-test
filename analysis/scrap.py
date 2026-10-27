import h5py # type: ignore
import matplotlib.pyplot as pl # type: ignore

f = h5py.File("archive/traces/trace.h5")
for digitiser in f:
    print(len(f[digitiser]['timestamp']))
    print(f[digitiser]['timestamp'][0],f[digitiser]['timestamp'][-1])



#trace.proto.h5 has run(s): 00104352 and 00104353 [0:26511], [26512:39078]
#trace.proto2.h5 has run(s): 00104354
#trace.proto3.h5 has run(s): 00104355 and 00104356 [0:6585], [6586:13150]
#trace.proto4.h5 has run(s): 00104357 and 00104358 [0:6576], [6577:10388]
#trace.proto5.h5 has run(s): 00104359
#trace.h5 has run(s): all

# Run 00104352: Start: Tue 09-Jun-2026 16:32:30, Slit 4.6mm, Time 00:10:59 (Frame: 119838597: 15:32:30.356286820 to 119865108: 15:43:33.097330880)
# Run 00104353: Start: Tue 09-Jun-2026 16:48:47, Slit 10mm,  Time 00:05:11 (Frame: 119877707: 15:48:48.077827220 to 119890273: 15:54:02.238322040)
# Run 00104354: Start: Tue 09-Jun-2026 16:59:16, Slit 20mm,  Time 00:02:43 (Frame: 119902850: 15:59:16.658817620 to 119909434: 16:02:01.259076740)
# Run 00104355: Start: Tue 09-Jun-2026 17:07:05, Slit 20mm,  Time 00:02:43 (Frame: 119921532: 16:07:05.259555680 to 119928117: 16:09:49.879815060)
# Run 00104356: Start: Tue 09-Jun-2026 17:14:53, Slit 20mm,  Time 00:02:44 (Frame: 119940283: 16:14:54.040294200 to 119946847: 16:17:39.400554840)
# Run 00104357: Start: Tue 09-Jun-2026 17:22:43, Slit 20mm,  Time 00:02:43 (Frame 119958943: 16:22:43.401033940 to 119965519: 16:25:27.801292780)
# Run 00104358: Start: Tue 09-Jun-2026 17:30:45, Slit 40mm,  Time 00:01:34 (Frame: 119978103: 16:30:45.741793680 to 119981914: 16:32:21.001943660)
# Run 00104359: Start: Tue 09-Jun-2026 17:37:54, Slit 100mm, Time 00:01:06 (Frame 119995253: 16:37:54.482469040 to 119997917: 16:39:02.242575960)
