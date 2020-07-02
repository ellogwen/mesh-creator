tool
extends Node

var _indicators = {
    "lines": {},
}

func add_line_global(lineId, from_pt, to_pt, color):
    _indicators.lines[lineId] = {
        "from": from_pt,
        "to": to_pt,
        "color": color
    }
    pass

func remove_line(lineId):
    _indicators.lines.erase(lineId)
    pass

func get_lines():
    return _indicators.lines.values()

