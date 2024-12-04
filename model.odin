package lre

import "core:fmt"
import la "core:math/linalg"
import "core:strings"
import "vendor:cgltf"

Model :: struct {
	meshes:          [dynamic]Mesh,
	color:           [3]f32,
	using transform: Transform,
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

extract_gltf_data :: proc(path: cstring) -> ^cgltf.data {

	options: cgltf.options
	data, results := cgltf.parse_file(options, path)
	if (results != cgltf.result.success) {

		fmt.printfln("failed to load gltf file")

	}


	if cgltf.load_buffers(options, data, path) != cgltf.result.success {

		fmt.printfln("failed to load gltf buffers")

	}

	return data
}

destroy_gltf_data :: proc(data: ^cgltf.data) {defer cgltf.free(data)}

extract_gltf_meshes :: proc(data: ^cgltf.data) -> (meshes: [dynamic]Mesh) {

	for &_mesh in data.meshes {

		primitives := _mesh.primitives
		for &_primitive in primitives {

			if (_primitive.attributes == nil) {
				continue
			}

			append(&meshes, mesh_from_primitive(&_primitive))


		}

	}


	return
}

// NOTE: finish this function
// get the models rest pose
extract_gltf_skeleton :: proc(data: ^cgltf.data) -> (skeleton: Skeleton) {

	resize(&skeleton.joints, len(data.nodes))
	resize(&skeleton.jointNames, len(data.nodes))

	for &_node, index in data.nodes {
		transform: Transform


		if (_node.has_translation) {

			transform.position = _node.translation
		}

		if (_node.has_rotation) {
			v: [4]f32 = _node.rotation
			transform.rotation = quaternion(w = v[3], x = v[0], y = v[1], z = v[2])
		}

		if (_node.has_scale) {
			transform.scaling = _node.scale
		} else {
			transform.scaling = {1, 1, 1}
		}


		skeleton.jointNames[index] = string(_node.name)
		skeleton.joints[index] = transform

		for &child in _node.children {

			skeleton.parents[get_node_id(data, child.name)] = u32(index)
		}
	}

	return
}

// NOTE: finish this function
// under construction 
extract_gltf_animations :: proc(data: ^cgltf.data) -> (clips: [dynamic]Clip) {

	for &_animation in data.animations {

		clip: Clip

		for &_channel in _animation.channels {

			sampler := _channel.sampler

			if (sampler.interpolation != .linear) {
				fmt.printfln("non linear interpolation!")
			}


			keyframes, values: [dynamic]f32
			get_scalar_values(&keyframes, 1, sampler.input)

			if _channel.target_path == .translation {
				get_scalar_values(&values, 3, sampler.output)
			}

			track: JointTrack
			track.target = u32(get_node_id(data, _channel.target_node.name))

			//fmt.printfln("{}", _channel.target_node.name)


		}
	}

	return
}

@(private = "file")
get_scalar_values :: proc(out: ^[dynamic]f32, compCount: u32, accessor: ^cgltf.accessor) {

	resize(out, u32(accessor.count) * compCount)

	for i: u32 = 0; i < u32(accessor.count); i += 1 {

		_ = cgltf.accessor_read_float(accessor, uint(i), &out[i * compCount], uint(compCount))


	}
}

@(private = "file")
get_node_id :: proc(data: ^cgltf.data, name: cstring) -> i32 {

	for &_node, index in data.nodes {
		if (_node.name == name) {

			return i32(index)

		}
	}
	fmt.printfln("failed to find the node id")

	return -1
}

@(private = "file")
mesh_from_primitive :: proc(_primitive: ^cgltf.primitive) -> (mesh: Mesh) {

	positions: [dynamic][3]f32
	normals: [dynamic][3]f32
	uvs: [dynamic][2]f32


	//first extract the vertex data(attributes) individually
	for &_attribute in _primitive.attributes {

		attrAccessor := _attribute.data
		compCount: u32 = 0

		#partial switch attrAccessor.type {

		case .vec2:
			compCount = 2


		case .vec3:
			compCount = 3


		case .vec4:
			compCount = 4
		}


		values: [dynamic]f32
		get_scalar_values(&values, compCount, attrAccessor)

		if (values != nil) {
			for i: u32 = 0; i < u32(attrAccessor.count); i += 1 {
				index := i * compCount

				#partial switch _attribute.type 
				{

				//get texture coordinates if any 
				case .texcoord:
					append(&uvs, [2]f32{values[index + 0], values[index + 1]})


				//get position coordinates 
				case .position:
					append(
						&positions,
						[3]f32{values[index + 0], values[index + 1], values[index + 2]},
					)


				//get normal coordinates 
				case .normal:
					append(
						&normals,
						[3]f32{values[index + 0], values[index + 1], values[index + 2]},
					)


				}
			}

		}


	}

	posCount := len(positions)

	resize(&mesh.vertices, posCount)

	for i: u32 = 0; i < u32(posCount); i += 1 {

		vert: Vertex

		vert.pos = positions[i]

		vert.norm = normals[i]

		vert.uv = [2]f32{0.0, 0.0}
		if (i < u32(len(uvs))) {

			vert.uv = uvs[i]

		}

		mesh.vertices[i] = vert

	}

	// check whether the mesh contains indices or not 
	// if not do nathing 
	indexCount := _primitive.indices.count

	if (indexCount != 0) {

		resize_dynamic_array(&mesh.indices, indexCount)
		for i: u32 = 0; i < u32(indexCount); i += 1 {

			mesh.indices[i] = u32(cgltf.accessor_read_index(_primitive.indices, uint(i)))

		}
	}

	//add mesh to dynamic array
	init_mesh(&mesh)

	return
}
