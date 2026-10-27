from lib import InputFile, constant, dependency, any_in_range, array, function, Chart
import json

file_name = "evaluation/input/my_temp.json"

file = InputFile("my-metrics", 20)
for i in range(9):
    file.append_events_count_metric(f"count_{i}", f"Events_{i}")

for i in range(9):
    file.append_muon_lifetime_metric(f"lifetime_{i}", f"Events_{i}", 17, { "min": 800, "max": 34800 })


digitisers_only_criteria_template = file.append_criteria_template(
    "digitisers-only",
    channels = constant("any"),
    digitiser_id = dependency({"is": function(1, 4)}),
    periods = constant("any"),
    frames = constant("any"),
)
bucket_template = file.append_bucket_template("bucket-template", 8, {"min": { "constant": 10 }, "max": { "constant": 100000 }})
digitiser_bucket = file.append_bucket("ByDigitiser", bucket_template, 8, {"use-template": digitisers_only_criteria_template})

for (title, metric, property, bar_chart) in [
        ("Event Count", "count", {"event-count": "channels-box-plot"}, "bar"),
        ("Muon Lifetime", "lifetime", {"muon-lifetime": "total-mean-with-sd"}, "bar")
    ]:
    chart = Chart(8, False, True, function(1,4), "Digitiser", title, f"{title} (Fixed Threshold)")
    #chart.set_grid(3,1)
    chart.append_series("2150", f"{metric}_0", "blue", "solid", property, digitiser_bucket, bar_chart, "x1", "y1")
    chart.append_series("2200", f"{metric}_1", "red", "solid", property, digitiser_bucket, bar_chart, "x1", "y1")
    chart.append_series("2250", f"{metric}_2", "green", "solid", property, digitiser_bucket, bar_chart, "x1", "y1")
    file.append_chart(chart)

    chart = Chart(8, False, True, function(1,4), "Digitiser", title, f"{title} (Differential Threshold)")
    chart.append_series("5", f"{metric}_3", "blue", "solid", property, digitiser_bucket, bar_chart, "x2", "y2")
    chart.append_series("20", f"{metric}_4", "red", "solid", property, digitiser_bucket, bar_chart, "x2", "y2")
    chart.append_series("35", f"{metric}_5", "green", "solid", property, digitiser_bucket, bar_chart, "x2", "y2")
    file.append_chart(chart)

    chart = Chart(8, False, True, function(1,4), "Digitiser", title, f"{title} (2nd Order Smoothing)")
    chart.append_series("2 sig.", f"{metric}_6", "blue", "solid", property, digitiser_bucket, bar_chart, "x3", "y3")
    chart.append_series("5 sig.", f"{metric}_7", "red", "solid", property, digitiser_bucket, bar_chart, "x3", "y3")
    chart.append_series("7 sig.", f"{metric}_8", "green", "solid", property, digitiser_bucket, bar_chart, "x3", "y3")
    file.append_chart(chart)

the_json = file.make_json()
the_file = open(file_name, mode = "w")
json.dump(the_json, the_file, indent = 2)