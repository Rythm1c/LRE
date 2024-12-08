package lre

import "core:fmt"
import la "core:math/linalg"
import "core:strings"
import gl "vendor:OpenGL"


shapes: map[string]Shape

// 3D gltf models
textureId: u32
textureSrc: string = "models/astronaut/textures/m_main_baseColor.png"
astronautSrc: cstring = "models/astronaut/scene.gltf"
astronaut: Model


model: matrix[4, 4]f32
view: matrix[4, 4]f32
proj: matrix[4, 4]f32
fov := la.to_radians(f32(45.0))

//shader sources/locations
fs_src: string = "shaders/shader.frag"
vs_src: string = "shaders/shader.vert"
anim_src: string = "shaders/animation.vert"
program: u32
animProgram: u32

elapsed: f32

init_world :: proc() {


	program, _ = gl.load_shaders_file(vs_src, fs_src)
	animProgram, _ = gl.load_shaders_file(anim_src, fs_src)

	use_shader_program(program)
	update_uniform_int(program, "tex", 0)

	use_shader_program(animProgram)
	update_uniform_int(animProgram, "tex", 0)

	// test shapes
	cube: Shape
	sphere: Shape
	torus: Shape
	platform: Shape

	platform.mesh = Cube()
	platform.color = {1, 1, 1}
	platform.position = {0, -1, 0}
	platform.scaling = {1e2, 1, 1e2}
	platform.gridCount = 30
	platform.enableGrid = 1
	//platform.transform.rotation = quaternion(w = 1, x = 0, y = 0, z = 0)
	shapes["platform"] = platform

	cube.mesh = Cube()
	cube.color = {0.9, 0.5, 0.6}
	cube.position = {0.0, 3.0, 15.0}
	cube.scaling = {1.0, 1.0, 1.0}
	//cube.rotation = quaternion(w = 1, x = 0, y = 0, z = 0)
	shapes["cube"] = cube

	torus.mesh = Torus(60)
	torus.color = {0.1, 0.9, 0.7}
	torus.position = {-6.0, 3.0, 13.0}
	torus.scaling = {3.0, 3.0, 3.0}
	//torus.rotation = quaternion(w = 1, x = 0, y = 0, z = 0)
	shapes["torus"] = torus

	sphere.mesh = Sphere(60, 60)
	sphere.color = {0.1, 0.4, 0.7}
	sphere.position = {5.0, 4.0, 15.0}
	sphere.scaling = {2.0, 2.0, 2.0}
	//sphere.rotation = quaternion(w = 1, x = 0, y = 0, z = 0)
	shapes["sphere"] = sphere

	astronautData := extract_gltf_data(astronautSrc)
	defer destroy_gltf_data(astronautData)
	astronaut.clips = extract_gltf_animations(astronautData)
	astronaut.skeleton = extract_gltf_skeleton(astronautData)
	astronaut.meshes = extract_gltf_meshes(astronautData)
	astronaut.color = {1.0, 1.0, 1.0}
	astronaut.position = {1.0, 4.0, 7.0}
	astronaut.scaling = {0.1, 0.1, 0.1}
	astronaut.rotation = la.quaternion_angle_axis_f32(la.to_radians(f32(180)), {0.0, 1.0, 0.0})
	textureId = texture_from_file(textureSrc)

	//debug_skeleton(&skeleton)


	camera.pos = {0.0, 7.0, -3.0}


}

update_world :: proc() {
	elapsed += f32(delta)

	view = camera_view()
	proj = la.matrix4_perspective_f32(fov, win_ratio(), 0.01, 600.0)

	//	update_model_animation(&astronaut, elapsed)

	//update once
	use_shader_program(program)
	update_uniform_mat4(program, "view", &view)
	update_uniform_mat4(program, "proj", &proj)
	update_uniform_vec3(program, "lDir", {-0.2, -0.6, 0.6})

	use_shader_program(animProgram)
	update_uniform_mat4(animProgram, "view", &view)
	update_uniform_mat4(animProgram, "proj", &proj)
	update_uniform_vec3(animProgram, "lDir", {-0.2, -0.6, 0.6})
}
//render everything
render_world :: proc() {

	render_static()
	render_animated()

}

render_static :: proc() {
	use_shader_program(program)
	//update per object
	for k, &v in shapes {

		model = transform_to_mat(v.transform)
		update_uniform_int(program, "textured", 0)
		update_uniform_int(program, "enableGrid", v.enableGrid)
		update_uniform_int(program, "gridCount", v.gridCount)
		update_uniform_mat4(program, "model", &model)
		update_uniform_vec3(program, "inCol", v.color)
		render_shape(&v)

	}

}

render_animated :: proc() {

	use_shader_program(animProgram)

	mats := get_model_animation(&astronaut)
	for &mat, index in mats {
		update_uniform_mat4(animProgram, fmt.aprint("boneMats[{}]", index), &mat)
	}

	model = transform_to_mat(astronaut.transform)
	update_uniform_int(animProgram, "textured", 1)
	gl.ActiveTexture(gl.TEXTURE0)
	bind_texture(textureId)
	update_uniform_int(animProgram, "enableGrid", 0)
	update_uniform_int(animProgram, "gridCount", 0)
	update_uniform_mat4(animProgram, "model", &model)
	update_uniform_vec3(animProgram, "inCol", astronaut.color)
	render_model(&astronaut)

}

destroy_world :: proc() {

	destroy_shader_programs({program})
	destroy_model(&astronaut)

	for k, &v in shapes {
		destroy_shape(&v)
	}

}
