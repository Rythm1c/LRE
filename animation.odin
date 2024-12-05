package lre

Vec3Track :: struct {
	times:  [dynamic]f32,
	frames: [dynamic][3]f32,
}

QuatTrack :: struct {
	times:  [dynamic]f32,
	frames: [dynamic]quaternion128,
}

JointTrack :: struct {
	//arranged in parllel to skeleton bones
	//in clip array 
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


set_duartion :: proc(clip: ^Clip) {

}
