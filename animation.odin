package lre

import "core:fmt"

JointTrack :: struct {
	//arranged in parllel to skeleton bones
	//targetId:     u32,
	targetName:   string,
	translations: [dynamic][3]f32,
	rotations:    [dynamic]quaternion128,
	scalings:     [dynamic][3]f32,
}

Clip :: struct {
	name:          string,
	start, finish: f32,
	tracks:        [dynamic]JointTrack,
}


set_duartion :: proc(clip: ^Clip) {

}

debug_clip_info :: proc(clip: ^Clip) {

	using fmt
	printfln("animation name: {}", clip.name)
	printfln("")
	for &track in clip.tracks {

		printfln("->track target joint: {}", track.targetName)
		{
			printfln("--->translations count: {}", len(track.translations))
			printfln("--->rotations count: {}", len(track.rotations))
			printfln("--->scalings count: {}", len(track.scalings))
		}
		printfln("")
	}
}
