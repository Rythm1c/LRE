package lre

import "core:fmt"

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
	targetName:   string,
	translations: Vec3Track,
	rotations:    QuatTrack,
	scalings:     Vec3Track,
}
//tracks are arranged in parallel to skeleton joints to match target joint's index
Clip :: struct {
	name:          string,
	start, finish: f32,
	tracks:        [dynamic]JointTrack,
}


set_duartion :: proc(clip: ^Clip) {

}

@(private="file")
start_time :: proc {
	start_time_vec3_track,
	start_time_quat_track,
}
@(private="file")
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
