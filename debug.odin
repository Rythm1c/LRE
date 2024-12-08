package lre

import "core:fmt"


HEADER :: "\033[95m"
CEND :: "\033[0m"


// NOTE: arrange this mess later 
// code needed some debugging
/* debug_clip_info :: proc(clip: ^Clip) {

	using fmt
	printfln("\033[95manimation name: {}\033[0m", clip.name)
	printfln("|")
	for &track in clip.tracks {

		printfln("|___>\033[94mtrack target joint: {}\033[0m", track.targetName)
		printfln(
			"|   |_______>\033[96mtranslations count: {}\033[0m",
			len(track.translations.frames),
		)
		for &v in track.translations.frames {

			printfln("|   |       |_______>: \033[92m(%.2f,%.2f,%.2f)\033[0m", v[0], v[1], v[2])
		}
		printfln("|   |_______>\033[96mrotations count: {}\033[0m", len(track.rotations.frames))
		for &v in track.rotations.frames {

			printfln(
				"|   |       |_______>: \033[92m(%.2f,%.2f,%.2f,%.2f)\033[0m",
				v.x,
				v.y,
				v.z,
				v.w,
			)
		}
		printfln("|   |_______>\033[96mscalings count: {}\033[0m", len(track.scalings.frames))
		for &v in track.scalings.frames {

			printfln("|   |       |_______>: \033[92m(%.2f,%.2f,%.2f)\033[0m", v[0], v[1], v[2])
		}


	}
}
 */
/* debug_skeleton :: proc(skeleton: ^Skeleton) {
	using fmt

	for &_joint, index in skeleton.restPose {

		printfln(
			"joint name: {}, id: {}, parent id: {}",
			skeleton.jointNames[index],
			index,
			skeleton.parents[index],
		)

		t := _joint.position
		printfln("translation: %.2f,%.2f,%.2f", t[0], t[1], t[2])

		r := _joint.rotation
		printfln("rotation: %.2f,%.2f,%.2f,%.2f", r.x, r.y, r.z, r.w)

		s := _joint.scaling
		printfln("scaling: %.2f,%.2f,%.2f\n", s[0], s[1], s[2])
	}
}
 */
