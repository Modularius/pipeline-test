from lib import InputFile, constant, any_in_range, function, Chart
import json

file_name = "evaluation/input/my_temp.json"

file = InputFile("my-metrics", 20)
for i in range(9):
    file.append_pulse_pair_differences_metric(f"filtered_pulse_pair_differences_{i}", f"Events_{i}", { "min": 0, "max": 10000 }, 32, { "min": 0, "max": 64 })
    
file.metrics[0]["intensity-filter"]["min"] = 2270
file.metrics[1]["intensity-filter"]["min"] = 2270
file.metrics[2]["intensity-filter"]["min"] = 2270
file.metrics[3]["intensity-filter"]["min"] = 2240
file.metrics[4]["intensity-filter"]["min"] = 2240
file.metrics[5]["intensity-filter"]["min"] = 2240
file.metrics[6]["intensity-filter"]["min"] = 2200
file.metrics[7]["intensity-filter"]["min"] = 2200
file.metrics[8]["intensity-filter"]["min"] = 2200

for i in range(9):
    file.append_pulse_pair_differences_metric(f"pulse_pair_differences_{i}", f"Events_{i}", { "min": 0, "max": 10000 }, 32, { "min": 0, "max": 64 })

any_criteria_template = file.append_criteria_template("any-criteria")
any_bucket_template = file.append_bucket_template("any-bucket-template", 1, {"min": { "constant": 10 }, "max": { "constant": 100000 }})
#any_message_bucket = file.append_bucket("ByAnyMessage", any_bucket_template, 1, {"use-template": any_criteria_template})
slit_4_6_message_bucket = file.append_bucket("Slit_4.6mm_Message", any_bucket_template, 1, {"use-template": any_criteria_template, "frames" : constant(any_in_range(119838597, 119865108))} )
slit_10_message_bucket  = file.append_bucket("Slit_10mm_Message",  any_bucket_template, 1, {"use-template": any_criteria_template, "frames" : constant(any_in_range(119877707, 119890273))} )
slit_20_message_bucket  = file.append_bucket("Slit_20mm_Message",  any_bucket_template, 1, {"use-template": any_criteria_template, "frames" : constant(any_in_range(119902850, 119909434))} )
slit_40_message_bucket  = file.append_bucket("Slit_40mm_Message",  any_bucket_template, 1, {"use-template": any_criteria_template, "frames" : constant(any_in_range(119958943, 119965519))} )
slit_100_message_bucket = file.append_bucket("Slit_100mm_Message", any_bucket_template, 1, {"use-template": any_criteria_template, "frames" : constant(any_in_range(119995253, 119997917))} )

bar_chart = "bar"
#bar_chart = {"scatter": "bar"}
property = {"pulse-pair-differences": "mean-sd"}
line_1 = "solid"
line_2 = "dash"

chart = Chart(1, False, True, function(1,2150), "Pulse Pair Time Diffs", "Count", "Pulse Pair Time Diffs: Fixed Threshold", (None, None), (None, None))
chart.set_grid(3,1)
for (title, metric, bucket, property, bar_chart, pattern, x_axis, y_axis) in [
        ("Fixed (2150)", "pulse_pair_differences_0", None, property, bar_chart, line_1, "x1", "y1"),
        ("Fixed (2200)", "pulse_pair_differences_1", None, property, bar_chart, line_1, "x2", "y2"),
        ("Fixed (2250)", "pulse_pair_differences_2", None, property, bar_chart, line_1, "x3", "y3"),
        ("Filtered Fixed (2150)", "filtered_pulse_pair_differences_0", None, property, bar_chart, line_2, "x1", "y1"),
        ("Filtered Fixed (2200)", "filtered_pulse_pair_differences_1", None, property, bar_chart, line_2, "x2", "y2"),
        ("Filtered Fixed (2250)", "filtered_pulse_pair_differences_2", None, property, bar_chart, line_2, "x3", "y3"),
    ]:
    chart.append_series("Slit 4.6mm", f"{metric}", "blue",   pattern, property, slit_4_6_message_bucket, bar_chart, title, x_axis, y_axis)
    chart.append_series("Slit 10mm",  f"{metric}", "red",    pattern, property, slit_10_message_bucket,  bar_chart, title, x_axis, y_axis)
    chart.append_series("Slit 20mm",  f"{metric}", "green",  pattern, property, slit_20_message_bucket,  bar_chart, title, x_axis, y_axis)
    chart.append_series("Slit 40mm",  f"{metric}", "black",  pattern, property, slit_40_message_bucket,  bar_chart, title, x_axis, y_axis)
    chart.append_series("Slit 100mm", f"{metric}", "purple", pattern, property, slit_100_message_bucket, bar_chart, title, x_axis, y_axis)
file.append_chart(chart)


chart = Chart(1, False, True, function(1,2000), "Pulse Pair Time Diffs", "Count", "Pulse Pair Time Diffs: Differential Threshold", (None, None), (None, None))
chart.set_grid(3,1)
for (title, metric, bucket, property, bar_chart, pattern, x_axis, y_axis) in [
        ("Differential (2150)", "pulse_pair_differences_3", None, property, bar_chart, line_1, "x1", "y1"),
        ("Differential (2200)", "pulse_pair_differences_4", None, property, bar_chart, line_1, "x2", "y2"),
        ("Differential (2250)", "pulse_pair_differences_5", None, property, bar_chart, line_1, "x3", "y3"),
        ("Filtered Differential (2150)", "filtered_pulse_pair_differences_3", None, property, bar_chart, line_2, "x1", "y1"),
        ("Filtered Differential (2200)", "filtered_pulse_pair_differences_4", None, property, bar_chart, line_2, "x2", "y2"),
        ("Filtered Differential (2250)", "filtered_pulse_pair_differences_5", None, property, bar_chart, line_2, "x3", "y3"),
    ]:
    chart.append_series("Slit 4.6mm", f"{metric}", "blue",   pattern, property, slit_4_6_message_bucket, bar_chart, title, x_axis, y_axis)
    chart.append_series("Slit 10mm",  f"{metric}", "red",    pattern, property, slit_10_message_bucket,  bar_chart, title, x_axis, y_axis)
    chart.append_series("Slit 20mm",  f"{metric}", "green",  pattern, property, slit_20_message_bucket,  bar_chart, title, x_axis, y_axis)
    chart.append_series("Slit 40mm",  f"{metric}", "black",  pattern, property, slit_40_message_bucket,  bar_chart, title, x_axis, y_axis)
    chart.append_series("Slit 100mm", f"{metric}", "purple", pattern, property, slit_100_message_bucket, bar_chart, title, x_axis, y_axis)
file.append_chart(chart)

chart = Chart(1, False, True, function(1,2000), "Pulse Pair Time Diffs", "Count", "Pulse Pair Time Diffs: 2nd Order Smoothing", (None, None), (None, None))
chart.set_grid(3,1)
for (title, metric, bucket, property, bar_chart, pattern, x_axis, y_axis) in [
        ("Smoothing (2150)", "pulse_pair_differences_6", None, property, bar_chart, line_1, "x1", "y1"),
        ("Smoothing (2200)", "pulse_pair_differences_7", None, property, bar_chart, line_1, "x2", "y2"),
        ("Smoothing (2250)", "pulse_pair_differences_8", None, property, bar_chart, line_1, "x3", "y3"),
        ("Filtered Smoothing (2150)", "filtered_pulse_pair_differences_6", None, property, bar_chart, line_2, "x1", "y1"),
        ("Filtered Smoothing (2200)", "filtered_pulse_pair_differences_7", None, property, bar_chart, line_2, "x2", "y2"),
        ("Filtered Smoothing (2250)", "filtered_pulse_pair_differences_8", None, property, bar_chart, line_2, "x3", "y3"),
    ]:
    chart.append_series("Slit 4.6mm", f"{metric}", "blue",   pattern, property, slit_4_6_message_bucket, bar_chart, title, x_axis, y_axis)
    chart.append_series("Slit 10mm",  f"{metric}", "red",    pattern, property, slit_10_message_bucket,  bar_chart, title, x_axis, y_axis)
    chart.append_series("Slit 20mm",  f"{metric}", "green",  pattern, property, slit_20_message_bucket,  bar_chart, title, x_axis, y_axis)
    chart.append_series("Slit 40mm",  f"{metric}", "black",  pattern, property, slit_40_message_bucket,  bar_chart, title, x_axis, y_axis)
    chart.append_series("Slit 100mm", f"{metric}", "purple", pattern, property, slit_100_message_bucket, bar_chart, title, x_axis, y_axis)
file.append_chart(chart)


the_json = file.make_json()
the_file = open(file_name, mode = "w")
json.dump(the_json, the_file, indent = 2)