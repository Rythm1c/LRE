package lre

JointTrack :: struct {
	target:     u32,
	transforms: [dynamic]Transform,
}

Clip :: struct {
	name:          string,
	start, finish: f32,
	tracks:        [dynamic]JointTrack,
}


set_duartion :: proc(clip: ^Clip) {

}
