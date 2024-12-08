package lre

//skeletal pose
Pose :: struct {
	transforms: [dynamic]Transform,
	parents:    [dynamic]i32,
}

Skeleton :: struct {
	invBindPose:  [dynamic]matrix[4, 4]f32 "inverse bind pose",
	jointNames:   [dynamic]string,
	restPose:     Pose "static pose",
	animatedPose: Pose "animated/dynamic pose",
}

// combine transforms to transform joints to world space
get_global_transform :: proc(pose: ^Pose, index: u32) -> (transform: Transform) {

	transform = pose.transforms[index]

	//-1 means no joints has no parent so stop combining
	p := pose.parents[index]
	for p != -1 {

		parentTransform := pose.transforms[p]

		transform = combine_transforms(&transform, &parentTransform)
		//transform->combine_transforms(&parentTransform)

		p = pose.parents[p]
	}

	return
}

get_global_transforms :: proc(pose: ^Pose) -> (out: [dynamic]Transform) {

	size := len(pose.transforms)
	resize(&out, size)

	for i: u32 = 0; i < u32(size); i += 1 {

		transform := get_global_transform(pose, i)

		out[i] = transform

	}

	return


}

update_animated_pose :: proc(skeleton: ^Skeleton, clip: ^Clip, elapsed: f32) {


	animatedPose := sample_clip(&skeleton.restPose.transforms, clip, elapsed)

	skeleton.animatedPose.transforms = animatedPose
}
