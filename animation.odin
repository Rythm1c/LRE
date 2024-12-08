package lre

import "core:fmt"
import la "core:math/linalg"

Vec3Track :: struct {
	times:  [dynamic]f32,
	frames: [dynamic][3]f32,
}

QuatTrack :: struct {
	times:  [dynamic]f32,
	frames: [dynamic]quaternion128,
}

JointTrack :: struct {
	//arranged in parallel to skeleton bones in clip struct 
	targetName:    string,
	start, finish: f32,
	translations:  Vec3Track,
	rotations:     QuatTrack,
	scalings:      Vec3Track,
}
//tracks are arranged in parallel to skeleton joints to match target joint's index
Clip :: struct {
	name:          string,
	start, finish: f32,
	tracks:        [dynamic]JointTrack,
}


sample_joint_track :: proc(
	track: ^JointTrack,
	refference: ^Transform,
	time: f32,
) -> (
	transform: Transform,
) {

	transform = refference^
	if (len(track.translations.frames) > 0) {

		transform.position = sample_vec3_track(&track.translations, time)
	}
	if (len(track.rotations.frames) > 0) {

		transform.rotation = sample_quat_track(&track.rotations, time)
	}
	if (len(track.scalings.frames) > 0) {

		transform.scaling = sample_vec3_track(&track.scalings, time)
	}

	return
}
sample_vec3_track :: proc(track: ^Vec3Track, time: f32) -> [3]f32 {

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
//hmmm.... abit of repetition over here for now
sample_quat_track :: proc(track: ^QuatTrack, time: f32) -> quaternion128 {

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


get_frame_index :: proc(times: ^[dynamic]f32, time: f32) -> i32 {


	size := len(times)
	if (size == 1) {
		return 0
	}

	for i: u32 = 0; int(i) < (size - 1); i += 1 {

		if (time < times[i + 1]) {

			return i32(i)

		}

	}

	fmt.printfln("couldn't find frame index!")

	return -1

}


set_duartion_clip :: proc(clip: ^Clip) {


	for &track in clip.tracks {
		set_duartion_joint_track(&track)

	}

}
@(private = "file")
set_duartion_joint_track :: proc(track: ^JointTrack) {

	start := start_time(&track.translations)
	end := end_time(&track.translations)

	if (start > start_time(&track.rotations)) {
		start = start_time(&track.rotations)

	} else if (start > start_time(&track.scalings)) {
		start = start_time(&track.scalings)

	}


	if (end < end_time(&track.rotations)) {
		end = end_time(&track.rotations)

	} else if (end < end_time(&track.scalings)) {
		end = end_time(&track.scalings)

	}


	track.start = start
	track.finish = end

}

@(private = "file")
start_time :: proc {
	start_time_vec3_track,
	start_time_quat_track,
}
@(private = "file")
end_time :: proc {
	end_time_vec3_track,
	end_time_quat_track,
}

@(private = "file")
start_time_vec3_track :: proc(track: ^Vec3Track) -> f32 {

	if (len(track.times) > 0) {
		return track.times[0]
	}

	fmt.print("no tracks were found!\nreturning start time 0")
	return 0
}
@(private = "file")
end_time_vec3_track :: proc(track: ^Vec3Track) -> f32 {
	if (len(track.times) > 0) {
		return track.times[len(track.times) - 1]
	}
	fmt.print("no tracks were found!\nreturning end time 0")
	return 0
}
@(private = "file")
start_time_quat_track :: proc(track: ^QuatTrack) -> f32 {

	if (len(track.times) > 0) {
		return track.times[0]
	}

	fmt.print("no tracks were found!\nreturning start time 0")
	return 0
}
@(private = "file")
end_time_quat_track :: proc(track: ^QuatTrack) -> f32 {
	if (len(track.times) > 0) {
		return track.times[len(track.times) - 1]
	}
	fmt.print("no tracks were found!\nreturning end time 0")
	return 0
}
