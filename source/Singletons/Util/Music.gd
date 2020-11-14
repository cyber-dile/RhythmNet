extends Node

func initBPM(tab): # Initialize a BPM table (Array<Float timeinms,Float bpm,?Float currentBeat>)
	for i in range(0,tab.size()):
		if (i == 0):
			tab[i].append(0) # this is the first beat! set its beat to 0.
		else:
			tab[i].append(tab[i-1][2] + (tab[i][0] - tab[i-1][0])/1000 * tab[i-1][1]/60) # calculate the current beat

func getBeat(tab, ms): # Get the beat of a song from its BPM table and the time in MS
	var thisBeat = tab[0]
	for dat in tab:
		if (ms > dat[0] and thisBeat[0] < dat[0]):
			thisBeat = dat
	return thisBeat[2] + (ms - thisBeat[0])/1000 * thisBeat[1]/60

func getTime(tab, beat): # Get the time of a song from its BPM table and the beat
	var thisBeat = tab[0]
	for dat in tab:
		if (beat > dat[2] and thisBeat[2] < dat[2]):
			thisBeat = dat
	return thisBeat[0] + ((beat - thisBeat[2]) * 60/thisBeat[1]) * 1000

func getAccuratePos(stream):
	var off = AudioServer.get_time_since_last_mix()
	if (off > 100):
		off = 0
	return stream.get_playback_position() + off
