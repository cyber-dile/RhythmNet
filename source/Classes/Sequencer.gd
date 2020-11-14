extends Node
class_name Sequencer

var queue = []
var lastSequenced

func sortFunc(a,b):
	return (a[0] <= b[0])

func sort():
	queue.sort_custom(self,"sortFunc")

func add(t, obj, fnc, data = {}):
	queue.append([t,obj,fnc,data])

func update(time):
	if (time != lastSequenced):
		lastSequenced = time
		var removed = 0
		if (queue.size() > 0):
			for i in range(queue.size()):
				var v = queue[i - removed]
				if (time > v[0]):
					var rm = v[1].call(v[2],v[3])
					if (rm):
						queue.remove(i - removed)
						removed += 1
				else:
					return
