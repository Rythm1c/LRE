package lre

import la "core:math/linalg"
import gl "vendor:OpenGL"

program: u32

// test shapes
cube: Mesh
sphere: Mesh
torus: Mesh
platform: Mesh

model: Mat4
view: Mat4
proj: Mat4
fov := la.to_radians(f32(45.0))

init_world :: proc() {

	fs_src: string = "shaders/shader.frag"
	vs_src: string = "shaders/shader.vert"

	program, _ = gl.load_shaders_file(vs_src, fs_src)

	platform = Cube()
	cube = Cube()
	torus = Torus(60)
	sphere = Sphere(60, 60)

}

update_world :: proc() {
	view = camera_view()
	proj = la.matrix4_perspective_f32(fov, win_ratio(), 0.01, 200.0)

	//update once
	use_shader_program(program)
	update_uniform_mat4(program, "view", &view)
	update_uniform_mat4(program, "proj", &proj)
	update_uniform_vec3(program, "lDir", {-0.2, -0.3, 0.9})
}

render_world :: proc() {

	use_shader_program(program)
	//update per object
	model = la.matrix4_translate_f32({0.0, 3.0, 15.0})
	update_uniform_mat4(program, "model", &model)
	update_uniform_vec3(program, "inCol", {0.9, 0.5, 0.6})
	render_mesh(&cube)

	model = la.matrix4_translate_f32({5.0, 4.0, 15.0}) * la.matrix4_scale_f32({2.0, 2.0, 2.0})
	update_uniform_mat4(program, "model", &model)
	update_uniform_vec3(program, "inCol", {0.1, 0.4, 0.7})
	render_mesh(&sphere)

	model = la.matrix4_translate_f32({-6.0, 3.0, 13.0}) * la.matrix4_scale_f32({3.0, 3.0, 3.0})
	update_uniform_mat4(program, "model", &model)
	update_uniform_vec3(program, "inCol", {0.1, 0.9, 0.7})
	render_mesh(&torus)

	model = la.matrix4_translate_f32({0.0, -1.0, 0.0}) * la.matrix4_scale_f32({400.0, 1.0, 400.0})
	update_uniform_mat4(program, "model", &model)
	update_uniform_vec3(program, "inCol", {0.2, 0.9, 0.8})
	render_mesh(&platform)
}

destroy_world :: proc() {

	destroy_shader_programs({program})
	destroy_mesh(&cube)
	destroy_mesh(&platform)
	destroy_mesh(&sphere)
	destroy_mesh(&torus)
}
