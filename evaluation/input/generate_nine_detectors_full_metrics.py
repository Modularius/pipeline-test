from lib import InputFile, constant, dependency, any_in_range, array, Chart
import json

file_name = "evaluation/input/my_temp.json"

file = InputFile("my-metrics", 20)
for i in range(9):
    file.append_intensity_graph_metric(f"intensity_{i}", f"Events_{i}", 256, { "min": 2000, "max": 2950 }, 5, f"Temp/diagnostic_{i}")
# Alter individual ranges
file.metrics[0]["interval"]["min"] = 2250
file.metrics[1]["interval"]["min"] = 2200
file.metrics[2]["interval"]["min"] = 2150

for i in range(9):
    file.append_muon_lifetime_metric(f"lifetime_{i}", f"Events_{i}", 17, { "min": 800, "max": 34800 })

for i in range(9):
    file.append_events_count_metric(f"count_{i}", f"Events_{i}")

slit_size_mm_array = file.append_array("SlitSizesMm", [4.6, 10, 20, 40, 100])
frame_min_array = file.append_array("FrameMin", [119838597, 119877707, 119902850, 119958943, 119995253])
frame_max_array = file.append_array("FrameMax", [119865108, 119890273, 119909434, 119965519, 119997917])


periods_and_frames_only_criteria_template = file.append_criteria_template(
    "periods-and-frames-only",
    channels = constant("any"),
    digitiser_id = constant("any"),
    periods = constant("any"),
    frames = dependency(any_in_range(array(frame_min_array), array(frame_max_array)))
)
slit_template = file.append_bucket_template("slit-template", 8, {"min": { "constant": 10 }, "max": { "constant": 100000 }})
slit_settings_bucket = file.append_bucket("SlitSettings", slit_template, 5, {"use-template": periods_and_frames_only_criteria_template})

for (title, metric, property) in [
        ("Noise Threshold", "intensity", "noise-threshold"),
        ("Intensity Difference", "intensity", "intensity-difference"),
        ("Muon Lifetime", "lifetime", "sd"),
        ("Event Count", "count", "sd")
    ]:
    chart = Chart(5, False, True, array("SlitSizesMm"), "Slit Size (mm)", title, f"{title} (Fixed Threshold)")
    chart.append_series("2150", f"{metric}_0", "blue", "solid", property, slit_settings_bucket, "x1", "y1")
    chart.append_series("2200", f"{metric}_1", "red", "solid", property, slit_settings_bucket, "x1", "y1")
    chart.append_series("2250", f"{metric}_2", "green", "solid", property, slit_settings_bucket, "x1", "y1")
    file.append_chart(chart)

    chart = Chart(5, False, True, array("SlitSizesMm"), "Slit Size (mm)", title, f"{title} (Differential Threshold)")
    chart.append_series("5", f"{metric}_3", "blue", "solid", property, slit_settings_bucket, "x2", "y2")
    chart.append_series("20", f"{metric}_4", "red", "solid", property, slit_settings_bucket, "x2", "y2")
    chart.append_series("35", f"{metric}_5", "green", "solid", property, slit_settings_bucket, "x2", "y2")
    file.append_chart(chart)

    chart = Chart(5, False, True, array("SlitSizesMm"), "Slit Size (mm)", title, f"{title} (2nd Order Smoothing)")
    chart.append_series("2 sig.", f"{metric}_6", "blue", "solid", property, slit_settings_bucket, "x3", "y3")
    chart.append_series("5 sig.", f"{metric}_7", "red", "solid", property, slit_settings_bucket, "x3", "y3")
    chart.append_series("7 sig.", f"{metric}_8", "green", "solid", property, slit_settings_bucket, "x3", "y3")
    file.append_chart(chart)

the_json = file.make_json()
the_file = open(file_name, mode = "w")
json.dump(the_json, the_file, indent = 2)