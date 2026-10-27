from lib import InputFile, constant, dependency, any_in_range, array, function, Chart
import json

file_name = "evaluation/input/my_temp.json"

file = InputFile("my-metrics", 20)

for i in range(9):
    file.append_muon_lifetime_metric(f"lifetime_{i}", f"Events_{i}", 17, { "min": 800, "max": 34800 })

for i in range(9):
    file.append_events_count_metric(f"count_{i}", f"Events_{i}")

frame_min = file.append_array("FrameMin", [119838597, 119877707, 119902850, 119958943, 119995253])
frame_max = file.append_array("FrameMax", [119865108, 119890273, 119909434, 119965519, 119997917])
slit_sizes_mm = file.append_array("SlitSizesMm", [4.6, 10, 20, 40, 100])

#digitisers_only_criteria_template = file.append_criteria_template("digitisers-only", digitiser_id = dependency({"is": function(1, 4)}))
#bucket_template = file.append_bucket_template("bucket-template", 8, {"min": { "constant": 0 }, "max": { "constant": 100000 }})
#digitiser_bucket = file.append_bucket("ByDigitiser", bucket_template, 8, {"use-template": digitisers_only_criteria_template})

frames_only_criteria_template = file.append_criteria_template("frames-only", frames = dependency(any_in_range(array(frame_min),array(frame_max))))
any_bucket_template = file.append_bucket_template("any-bucket-template", 5, {"min": { "constant": 10 }, "max": { "constant": 100000 }})
by_slit_bucket = file.append_bucket("by-slit-bucket", any_bucket_template, 5, {"use-template": frames_only_criteria_template})

for (x_axis_width, title, y_axis_label, metric, bucket, property, bar_chart) in [
        (5, "Muon Lifetime", "Muon Lifetime (ns)", "lifetime", by_slit_bucket, {"muon-lifetime": "channels-box-plot"}, {"scatter": "line"}),
        (5, "Event Count", "Event Count", "count", by_slit_bucket, {"event-count": "total-mean-with-sd"}, {"scatter": "line"}),
    ]:
    chart = Chart(x_axis_width, False, True, array(slit_sizes_mm), "Slit Size (mm)", y_axis_label, f"{title}", (None, 280), (None, 0.2))
    chart.set_grid(3,1)
    chart.append_series("2150", f"{metric}_0", "blue", "solid", property, bucket, bar_chart, "Fixed Threshold", "x1", "y1")
    chart.append_series("2200", f"{metric}_1", "red", "solid", property, bucket, bar_chart, "Fixed Threshold", "x1", "y1")
    chart.append_series("2250", f"{metric}_2", "green", "solid", property, bucket, bar_chart, "Fixed Threshold", "x1", "y1")
    #file.append_chart(chart)

    #chart = Chart(8, False, True, function(1,0), "Channel", title, f"{title} (Differential Threshold)")
    chart.append_series("5", f"{metric}_3", "blue", "solid", property, bucket, bar_chart, "Differential Threshold", "x2", "y2")
    chart.append_series("20", f"{metric}_4", "red", "solid", property, bucket, bar_chart, "Differential Threshold", "x2", "y2")
    chart.append_series("35", f"{metric}_5", "green", "solid", property, bucket, bar_chart, "Differential Threshold", "x2", "y2")
    #file.append_chart(chart)

    #chart = Chart(8, False, True, function(1,0), "Channel", title, f"{title} (2nd Order Smoothing)")
    chart.append_series("2 sig.", f"{metric}_6", "blue", "solid", property, bucket, bar_chart, "2nd Order Smoothing", "x3", "y3")
    chart.append_series("5 sig.", f"{metric}_7", "red", "solid", property, bucket, bar_chart, "2nd Order Smoothing", "x3", "y3")
    chart.append_series("7 sig.", f"{metric}_8", "green", "solid", property, bucket, bar_chart, "2nd Order Smoothing", "x3", "y3")
    file.append_chart(chart)

the_json = file.make_json()
the_file = open(file_name, mode = "w")
json.dump(the_json, the_file, indent = 2)