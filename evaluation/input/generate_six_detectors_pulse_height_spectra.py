from lib import InputFile, constant, dependency, any_in_range, array, function, Chart
import json

file_name = "evaluation/input/my_temp.json"

file = InputFile("my-metrics", 20)
for i in range(6):
    file.append_pulse_height_spectra_metric(f"pulse_height_spectra_{i}", f"Events_{i}", 96, { "min": 2000, "max": 2950 })
# Alter individual ranges
file.metrics[0]["interval"]["min"] = 2200
file.metrics[1]["interval"]["min"] = 2200


any_criteria_template = file.append_criteria_template("any-criteria")
any_bucket_template = file.append_bucket_template("any-bucket-template", 1, {"min": { "constant": 10 }, "max": { "constant": 100000 }})
#any_message_bucket = file.append_bucket("ByAnyMessage", any_bucket_template, 1, {"use-template": any_criteria_template})
slit_4_6_message_bucket = file.append_bucket("Slit_4.6mm_Message", any_bucket_template, 1, {"use-template": any_criteria_template, "frames" : constant(any_in_range(119838597, 119865108))} )
slit_10_message_bucket  = file.append_bucket("Slit_10mm_Message",  any_bucket_template, 1, {"use-template": any_criteria_template, "frames" : constant(any_in_range(119877707, 119890273))} )
slit_20_message_bucket  = file.append_bucket("Slit_20mm_Message",  any_bucket_template, 1, {"use-template": any_criteria_template, "frames" : constant(any_in_range(119902850, 119909434))} )
slit_40_message_bucket  = file.append_bucket("Slit_40mm_Message",  any_bucket_template, 1, {"use-template": any_criteria_template, "frames" : constant(any_in_range(119958943, 119965519))} )
slit_100_message_bucket = file.append_bucket("Slit_100mm_Message", any_bucket_template, 1, {"use-template": any_criteria_template, "frames" : constant(any_in_range(119995253, 119997917))} )

chart = Chart(1, False, True, function(1,2150), "Pulse Height", "Count", "Pulse Height Spectra: Fixed Threshold", (None, None), (None, None))
chart.set_grid(2,1)
for (title, metric, bucket, property, bar_chart, x_axis, y_axis) in [
        ("Fixed Threshold (2200)", "pulse_height_spectra_0", None, {"pulse-height-spectra": "mean-sd"}, {"scatter": "line"}, "x1", "y1"),
        ("Fixed Pyramid (2200)", "pulse_height_spectra_1", None, {"pulse-height-spectra": "mean-sd"}, {"scatter": "line"}, "x2", "y2"),
    ]:
    chart.append_series("Slit 4.6mm", f"{metric}", "blue",   "solid", property, slit_4_6_message_bucket, bar_chart, title, x_axis, y_axis)
    chart.append_series("Slit 10mm",  f"{metric}", "red",    "solid", property, slit_10_message_bucket,  bar_chart, title, x_axis, y_axis)
    chart.append_series("Slit 20mm",  f"{metric}", "green",  "solid", property, slit_20_message_bucket,  bar_chart, title, x_axis, y_axis)
    chart.append_series("Slit 40mm",  f"{metric}", "black",  "solid", property, slit_40_message_bucket,  bar_chart, title, x_axis, y_axis)
    chart.append_series("Slit 100mm", f"{metric}", "purple", "solid", property, slit_100_message_bucket, bar_chart, title, x_axis, y_axis)
file.append_chart(chart)


chart = Chart(1, False, True, function(1,2000), "Pulse Height", "Count", "Pulse Height Spectra: Differential Threshold", (None, None), (None, None))
chart.set_grid(2,1)
for (title, metric, bucket, property, bar_chart, x_axis, y_axis) in [
        ("Differential Threshold (20)",  "pulse_height_spectra_2", None, {"pulse-height-spectra": "mean-sd"}, {"scatter": "line"}, "x1", "y1"),
        ("Differential Pyramid (20)", "pulse_height_spectra_3", None, {"pulse-height-spectra": "mean-sd"}, {"scatter": "line"}, "x2", "y2"),
    ]:
    chart.append_series("Slit 4.6mm", f"{metric}", "blue",   "solid", property, slit_4_6_message_bucket, bar_chart, title, x_axis, y_axis)
    chart.append_series("Slit 10mm",  f"{metric}", "red",    "solid", property, slit_10_message_bucket,  bar_chart, title, x_axis, y_axis)
    chart.append_series("Slit 20mm",  f"{metric}", "green",  "solid", property, slit_20_message_bucket,  bar_chart, title, x_axis, y_axis)
    chart.append_series("Slit 40mm",  f"{metric}", "black",  "solid", property, slit_40_message_bucket,  bar_chart, title, x_axis, y_axis)
    chart.append_series("Slit 100mm", f"{metric}", "purple", "solid", property, slit_100_message_bucket, bar_chart, title, x_axis, y_axis)
file.append_chart(chart)

chart = Chart(1, False, True, function(1,2000), "Pulse Height", "Count", "Pulse Height Spectra: 2nd Order Smoothing", (None, None), (None, None))
chart.set_grid(2,1)
for (title, metric, bucket, property, bar_chart, x_axis, y_axis) in [
        ("2nd Order Smoothing (5 sig.)", "pulse_height_spectra_4", None, {"pulse-height-spectra": "mean-sd"}, {"scatter": "line"}, "x1", "y1"),
        ("2nd Order Pyramid (5 sig.)", "pulse_height_spectra_5", None, {"pulse-height-spectra": "mean-sd"}, {"scatter": "line"}, "x2", "y2"),
    ]:
    chart.append_series("Slit 4.6mm", f"{metric}", "blue",   "solid", property, slit_4_6_message_bucket, bar_chart, title, x_axis, y_axis)
    chart.append_series("Slit 10mm",  f"{metric}", "red",    "solid", property, slit_10_message_bucket,  bar_chart, title, x_axis, y_axis)
    chart.append_series("Slit 20mm",  f"{metric}", "green",  "solid", property, slit_20_message_bucket,  bar_chart, title, x_axis, y_axis)
    chart.append_series("Slit 40mm",  f"{metric}", "black",  "solid", property, slit_40_message_bucket,  bar_chart, title, x_axis, y_axis)
    chart.append_series("Slit 100mm", f"{metric}", "purple", "solid", property, slit_100_message_bucket, bar_chart, title, x_axis, y_axis)
file.append_chart(chart)


the_json = file.make_json()
the_file = open(file_name, mode = "w")
json.dump(the_json, the_file, indent = 2)