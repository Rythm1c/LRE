package lre

import "core:fmt"
import la "core:math/linalg"
import "core:strings"
import "vendor:cgltf"

Model :: struct {
	meshes:          [dynamic]Mesh,
	color:           [3]f32,
	using transform: Transform,
	skeleton:        Skeleton,
	clips:           [dynamic]Clip,
	currentAnim:     u32,
}

update_model_animation :: proc(model: ^Model, elapsed: f32) {

	skeleton := &model.skeleton

	clip := &model.clips[model.currentAnim]

	update_animated_pose(skeleton, clip, elapsed)
}

get_model_animation :: proc(model: ^Model) -> (out: [dynamic]matrix[4, 4]f32) {

	animatedPose := &model.skeleton.animatedPose
	invMats := &model.skeleton.invBindPose

	pose := get_global_transforms(animatedPose)
	resize(&out, len(pose))

	for &transform, index in pose {

		out[index] = transform_to_mat(transform) * invMats[index]
	}


	return out

}

render_model :: proc(model: ^Model) {

	for &mesh in model.meshes {

		render_mesh(&mesh)

	}

}

destroy_model :: proc(model: ^Model) {

	for &mesh in model.meshes {

		destroy_mesh(&mesh)

	}
}
