package lre

import "core:fmt"
import la "core:math/linalg"

//not the cleanest approach 

Track :: struct($T: typeid) {
	times:  [dynamic]f32,
	frames: [dynamic]T,
}
Vec3Track :: Track([3]f32)
QuatTrack :: Track(quaternion128)

JointTrack :: struct {
	//arranged in parallel to skeleton bones in clip struct 
	targetName:   string,
	targetId:     u32,
	start, end:   f32,
	translations: Vec3Track,
	rotations:    QuatTrack,
	scalings:     Vec3Track,
}
//
Clip :: struct {
	name:       string,
	start, end: f32,
	tracks:     [dynamic]JointTrack "tracks are arranged in parallel to skeleton joints to match target joint's index",
}

set_clip_duration :: proc(clip: ^Clip) {

	/* start, finish: f32 */
	set := false

	for &track in clip.tracks {
		set_duration_joint_track(&track)
		if !set {

			clip.start = track.start
			clip.end = track.end
		} else {

			if clip.start > track.start {

				clip.start = track.start
			}

			if clip.end < track.end {

				clip.end = track.end
			}
		}

	}


}

//extract sample animated pose with respect to the elaplsed time  
sample_clip :: proc(
	ref: ^[dynamic]Transform,
	clip: ^Clip,
	time: f32,
) -> (
	out: [dynamic]Transform,
) {

	out = ref^

	for &track in clip.tracks {

		targetIndex := track.targetId

		animated := sample_joint_track(&track, &out[targetIndex], time)

		out[targetIndex] = animated
	}

	return
}


@(private = "file")
sample_joint_track :: proc(
	track: ^JointTrack,
	ref: ^Transform,
	time: f32,
) -> (
	transform: Transform,
) {

	transform = ref^
	if (len(track.translations.frames) > 0) {

		transform.position = sample_track(&track.translations, time)
	}
	if (len(track.rotations.frames) > 0) {

		transform.rotation = sample_track(&track.rotations, time)
	}
	if (len(track.scalings.frames) > 0) {

		transform.scaling = sample_track(&track.scalings, time)
	}

	return
}
/*  */
@(private = "file")
sample_track :: proc(track: ^Track($T), time: f32) -> T {
	/* if (len(track.times) == 1) {
		return track.frames[0]
	} */
	startFrame := get_frame_index(&track.times, time)
	endFrame := startFrame + 1
	//not very good at naming 
	startTime := track.times[startFrame]
	endTime := track.times[endFrame]

	duration := startTime - endTime
	currTime := la.mod(time, duration)
	difference := currTime - startTime

	percentage := difference / duration

	result := la.lerp(track.frames[startFrame], track.frames[endFrame], percentage)

	return result
}

@(private = "file")
get_frame_index :: proc(times: ^[dynamic]f32, time: f32) -> i32 {


	size := len(times)
	if (size == 1) {
		return 0
	}

	start := times[0]
	end := times[size - 1]
	duration := start - end
	trimmed := la.mod(time, duration)

	for i: u32 = 0; int(i) < (size - 1); i += 1 {

		if (trimmed < times[i + 1]) {

			return i32(i)

		}

	}

	fmt.printfln("couldn't find frame index!")

	return -1

}


@(private = "file")
set_duration_joint_track :: proc(track: ^JointTrack) {

	start := track_start_time(&track.translations)
	end := track_end_time(&track.translations)
	//set starting time
	if (start > track_start_time(&track.rotations)) {

		start = track_start_time(&track.rotations)

	} else if (start > track_start_time(&track.scalings)) {

		start = track_start_time(&track.scalings)

	}
	//set ending time
	if (end < track_end_time(&track.rotations)) {

		end = track_end_time(&track.rotations)

	} else if (end < track_end_time(&track.scalings)) {

		end = track_end_time(&track.scalings)

	}


	track.start = start
	track.end = end

}


@(private = "file")
track_start_time :: proc(track: ^Track($T)) -> f32 {

	if (len(track.times) > 0) {

		return track.times[0]
	}

	fmt.printfln("no tracks were found!\nreturning start time 0")
	return 0
}
@(private = "file")
track_end_time :: proc(track: ^Track($T)) -> f32 {
	if (len(track.times) > 0) {

		return track.times[len(track.times) - 1]
	}

	fmt.printfln("no tracks were found!\nreturning end time 0")
	return 0
}
