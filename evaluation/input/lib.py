def constant(value):
    return {"constant": value}

def dependency(value):
    return {"dependency": value}

def array(value):
    return { "array": value }

def function(scale, value_at_zero):
    return { "function": { "scale": scale, "value-at-zero": value_at_zero } }

def any_in_range(min, max):
    return {"any-in-range": { "min": min, "max": max }}

class InputFile:
    def __init__(self, metrics_json_name, idle_time_exceeded_sec):
        self.idle_time_exceeded_sec = idle_time_exceeded_sec
        self.metrics_json_name = metrics_json_name
        self.events_topics = []
        self.metrics = []
        self.criteria_templates = []
        self.bucket_templates = []
        self.arrays = []
        self.algorithms = []
        self.waveforms = []
        self.buckets = []
        self.charts = []

    def append_array(self, name, values):
        self.arrays.append({"name": name, "values": values})
        return name

    def append_pulse_height_spectra_metric(self, name, topic, num_bins, interval):
        self.metrics.append({
            "name": name, "metric-type": "pulse-height-spectra",
            "topic": topic,
            "num-bins": num_bins,
            "interval": interval
        })
        return name
    
    def append_pulse_pair_differences_metric(self, name, topic, intensity_filter, num_bins, interval):
        self.metrics.append({
            "name": name, "metric-type": "pulse-pair-differences",
            "topic": topic,
            "intensity-filter": intensity_filter,
            "num-bins": num_bins,
            "interval": interval
        })
        return name

    def append_intensity_graph_metric(self, name, topic, num_bins, interval, max_degree, noise_estimate, transition_estimate, events_estimate, save_diagnostic_as):
        self.metrics.append({
            "name": name, "metric-type": "intensity-graph",
            "topic": topic,
            "num-bins": num_bins,
            "interval": interval,
            "max-degree": max_degree,
            "save-diagnostic-as": save_diagnostic_as,
            "noise-peak-estimate": noise_estimate,
            "transition-point-estimate": transition_estimate,
            "events-peak-estimate": events_estimate,
        })
        return name

    def append_muon_lifetime_metric(self, name, topic, num_bins, interval):
        self.metrics.append({
            "name": name, "metric-type": "muon-lifetime",
            "topic": topic,
            "num-bins": num_bins,
            "interval": interval,
        })
        return name

    def append_events_count_metric(self, name, topic):
        self.metrics.append({
            "name": name, "metric-type": "event-count",
            "topic": topic,
        })
        return name

    def append_criteria_template(self, name, channels = constant("any"), digitiser_id = constant("any"), periods = constant("any"), frames = constant("any")):
        self.criteria_templates.append({
            "name": name,
            "channels": channels,
            "digitiser-ids": digitiser_id,
            "periods": periods,
            "frames": frames
        })
        return name

    def append_bucket_template(self, name, number, limits):
        self.bucket_templates.append({
            "name": name,
            "algorithm": "threshold-only",
            "waveform": "gaussian",
            "number": number,
            "limits": limits
        })
        return name

    def append_bucket(self, name, use_template, number, critera):
        self.buckets.append({
            "name": name,
            "use-template": use_template,
            "number": number,
            "criteria": critera
        })
        return name

    def append_chart(self, chart):
        self.charts.append(chart.make_json())

    def make_json(self):
        topics = set()
        for metric in self.metrics:
            topics.add(metric["topic"])
        self.events_topics = list(topics)
        self.events_topics.sort()
        return {
            "metrics-json-name": self.metrics_json_name,
            "events-topics": self.events_topics,
            "metrics": self.metrics,
            "trigger-charts-when": {"idle-time-exceeded-sec": self.idle_time_exceeded_sec},
            "idle-time-sec": 20,
            "templates": {
                "criteria-templates": self.criteria_templates,
                "bucket-templates": self.bucket_templates,
                "arrays": self.arrays,
                "algorithms": [{
                    "name": "threshold-only",
                    "fixed-threshold": {
                        "threshold": {"constant": 220 },
                        "duration": {"constant": 1 },
                        "cool_down": {"constant": 5 }
                    }
                }],
                "waveforms": [{
                    "name" : "gaussian",
                    "pulse-type": "gaussian",
                    "sd": {"constant": 20 }
                }]
            },
            "buckets": self.buckets,
            "charts": self.charts
        }

class Chart:
    def __init__(self, width: int, output_to_json: bool, output_to_html: bool, x_axis: dict, x_axis_label: str, y_axis_label: str, title: str, chart_size: tuple[int | None, int | None], chart_gaps : tuple[float | None, float | None]):
        self.width = width
        self.output_to_json = output_to_json
        self.output_to_html = output_to_html
        self.x_axis = x_axis
        self.x_axis_label = x_axis_label
        self.y_axis_label = y_axis_label
        self.title = title
        self.series = []
        self.num_rows = 1
        self.num_cols = 1
        self.chart_size = chart_size
        self.chart_gaps = chart_gaps
        
    def set_grid(self, num_rows, num_cols):
        self.num_rows = num_rows
        self.num_cols = num_cols

    def append_series(self, name, metric, line_colour, line_style, property, from_bucket, series_mode, legend_group_title, x_axis, y_axis):
        self.series.append({
            "metric": metric,
            "name": name,
            "line-colour": line_colour, "line-style": line_style,
            "property": property, "from-bucket": from_bucket,
            "x-axis": x_axis, "y-axis": y_axis, "series-type": series_mode,
            "legend-group-title": legend_group_title
        })

    def make_json(self):
        json = {
            "width": self.width,
            "output-to-json": self.output_to_json,
            "output-to-html": self.output_to_html,
            "x-axis": self.x_axis,
            "x-axis-label": self.x_axis_label,
            "y-axis-label": self.y_axis_label,
            "title": self.title,
            "series": self.series,
            "num-rows": self.num_rows,
            "num-cols": self.num_cols
        }
        if self.chart_size[0]:
            json["width"] = self.chart_size[0]
        if self.chart_size[1]:
            json["height"] = self.chart_size[1]
        if self.chart_gaps[0]:
            json["x-gap-fraction"] = self.chart_gaps[0]
        if self.chart_gaps[1]:
            json["y-gap-fraction"] = self.chart_gaps[1]
        return json