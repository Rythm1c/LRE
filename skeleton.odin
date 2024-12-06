package lre

Skeleton :: struct {
	restPose:        [dynamic]Transform,
	inverseBindPose: [dynamic]Mat4,
	parents:         [dynamic]i32,
	jointNames:      [dynamic]string,
}

// combine transforms to transform joints to world space
get_global_transform :: proc(skeleton: ^Skeleton, index: u32) -> (transform: Transform) {

	transform = skeleton.restPose[index]

	//-1 means no joints has no parent so stop combining
	p := skeleton.parents[index]
	for p != -1 {

		parentTransform := skeleton.restPose[p]

		transform = combine_transforms(&transform, &parentTransform)

		p = skeleton.parents[p]
	}

	return
}
