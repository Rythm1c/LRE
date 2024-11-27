package lre

import "base:runtime"
import "core:c"
import "core:fmt"
import "core:os"
import "core:strings"

import la "core:math/linalg"
import gl "vendor:OpenGL"


destroy_shaders :: proc(shaders: []u32) {

	for shader in shaders {
		gl.DeleteShader(shader)
	}

}

destroy_shader_programs :: proc(programs: []u32) {

	for program in programs {
		gl.DeleteProgram(program)
	}
}

use_shader_program :: proc(program: u32) {

	gl.UseProgram(program)

}

@(private)
uniform_location :: proc(id: u32, name: string) -> i32 {

	name_copy := cstring(raw_data(name))
	return gl.GetUniformLocation(id, name_copy)
}

update_uniform_int :: proc(id: u32, name: string, v: i32) {

	location := uniform_location(id, name)
	gl.Uniform1i(location, v)

}

update_uniform_float :: proc(id: u32, name: string, v: f32) {

	location := uniform_location(id, name)
	gl.Uniform1f(location, v)

}

update_uniform_vec3 :: proc(id: u32, name: string, v: [3]f32) {

	location := uniform_location(id, name)
	gl.Uniform3f(location, v[0], v[1], v[2])


}

update_uniform_mat4 :: proc(id: u32, name: string, mat: ^la.Matrix4f32) {

	location := uniform_location(id, name)
	gl.UniformMatrix4fv(location, 1, false, &mat[0, 0])
}
