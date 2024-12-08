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

destroy_gltf_data :: proc(data: ^cgltf.data) {defer cgltf.free(data)}
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


extract_gltf_meshes :: proc(data: ^cgltf.data) -> (meshes: [dynamic]Mesh) {

	skin: ^cgltf.skin
	ids: [dynamic]u32

	if (len(data.skins) > 0) {

		skin = &data.skins[0]
		resize(&ids, len(skin.joints))

		for &_joint, index in skin.joints {
			ids[index] = u32(get_node_id(&data.nodes, _joint.name))
			fmt.printfln("{}", ids[index])
		}
	}


	for &_mesh in data.meshes {

		primitives := _mesh.primitives


		for &_primitive in primitives {

			if (_primitive.attributes == nil) {continue}

			append(&meshes, mesh_from_primitive(&_primitive, &ids))


		}

	}


	return
}

// NOTE: finish this function
// get the models rest pose
extract_gltf_skeleton :: proc(data: ^cgltf.data) -> (skeleton: Skeleton) {

	resize(&skeleton.restPose, len(data.nodes))
	resize(&skeleton.jointNames, len(data.nodes))
	resize(&skeleton.parents, len(data.nodes))
	resize(&skeleton.inverseBindPose, len(data.nodes))

	// for initializing the root node to -1 to make things easier
	for &parent in skeleton.parents {
		parent = -1
	}

	for &_node, index in data.nodes {
		transform: Transform

		//____________________________________________________________________________________
		//____________________________________________________________________________________
		if (_node.has_translation) {

			transform.position = _node.translation
		}
		//____________________________________________________________________________________
		//____________________________________________________________________________________
		if (_node.has_rotation) {
			v: [4]f32 = _node.rotation
			transform.rotation = quaternion(w = v[3], x = v[0], y = v[1], z = v[2])
		}
		//____________________________________________________________________________________
		//____________________________________________________________________________________
		if (_node.has_scale) {
			transform.scaling = _node.scale
		} else {
			transform.scaling = {1, 1, 1}
		}
		//____________________________________________________________________________________
		//____________________________________________________________________________________
		skeleton.jointNames[index] = string(_node.name)
		skeleton.restPose[index] = transform

		for &child in _node.children {

			skeleton.parents[get_node_id(&data.nodes, child.name)] = i32(index)
		}
	}

	//assume theres only one skin in mesh 
	for &_skin in data.skins {

		//holds the actual matrices
		fvs: [dynamic]f32
		get_scalar_values(&fvs, 16, _skin.inverse_bind_matrices)
		count := _skin.inverse_bind_matrices.count


		for i: u32 = 0; i < u32(count); i += 1 {

			j := i * 16
			inverseMat := matrix[4, 4]f32{
				fvs[j + 0], fvs[j + 1], fvs[j + 2], fvs[j + 3], 
				fvs[j + 4], fvs[j + 5], fvs[j + 6], fvs[j + 7], 
				fvs[j + 8], fvs[j + 9], fvs[j + 10], fvs[j + 11], 
				fvs[j + 12], fvs[j + 13], fvs[j + 14], fvs[j + 15], 
			}

			jointName := _skin.joints[i].name
			skeleton.inverseBindPose[get_node_id(&data.nodes, jointName)] = la.transpose(
				inverseMat,
			)

		}


	}

	return
}

// NOTE: finish this function
// under construction 
extract_gltf_animations :: proc(data: ^cgltf.data) -> (clips: [dynamic]Clip) {

	for &_animation in data.animations {

		clip: Clip
		clip.name = string(_animation.name)
		// resize and set node names and indexes
		resize(&clip.tracks, len(data.nodes))
		for &_node, index in data.nodes {
			clip.tracks[index].targetName = string(_node.name)
		}

		for &_channel in _animation.channels {

			targetId := u32(get_node_id(&data.nodes, _channel.target_node.name))

			proccess_channel(&_channel, targetId, &clip)
		}

		append(&clips, clip)
	}

	return
}


extract_gltf_materials :: proc(data: ^cgltf.data) {}

//helpers
@(private = "file")
get_scalar_values :: proc(out: ^[dynamic]f32, compCount: u32, accessor: ^cgltf.accessor) {

	resize(out, u32(accessor.count) * compCount)

	for i: u32 = 0; i < u32(accessor.count); i += 1 {

		_ = cgltf.accessor_read_float(accessor, uint(i), &out[i * compCount], uint(compCount))


	}
}

@(private = "file")
get_node_id :: proc(nodes: ^[]cgltf.node, name: cstring) -> i32 {

	for &_node, index in nodes {
		if (_node.name == name) {

			return i32(index)

		}
	}
	fmt.printfln("failed to find the node id")

	return -1
}

@(private = "file")
mesh_from_primitive :: proc(_primitive: ^cgltf.primitive, skin: ^[dynamic]u32) -> (mesh: Mesh) {

	positions: [dynamic][3]f32
	normals: [dynamic][3]f32
	uvs: [dynamic][2]f32
	weights: [dynamic][4]f32
	ids: [dynamic][4]u32


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

		//floating point values
		fvs: [dynamic]f32
		get_scalar_values(&fvs, compCount, attrAccessor)

		//if (fvs == nil) {continue}

		for i: u32 = 0; i < u32(attrAccessor.count); i += 1 {
			index := i * compCount

			#partial switch _attribute.type 
			{
			//____________________________________________________________________________________
			//____________________________________________________________________________________
			//get texture coordinates if any 
			case .texcoord:
				append(&uvs, [2]f32{fvs[index + 0], fvs[index + 1]})

			//____________________________________________________________________________________
			//____________________________________________________________________________________
			//get position coordinates 
			case .position:
				append(&positions, [3]f32{fvs[index + 0], fvs[index + 1], fvs[index + 2]})

			//____________________________________________________________________________________
			//____________________________________________________________________________________
			//get normal coordinates 
			case .normal:
				append(&normals, [3]f32{fvs[index + 0], fvs[index + 1], fvs[index + 2]})
			//____________________________________________________________________________________
			//____________________________________________________________________________________
			//get weights of influencing joints 
			case .weights:
				append(
					&weights,
					[4]f32{fvs[index + 0], fvs[index + 1], fvs[index + 2], fvs[index + 3]},
				)
			//____________________________________________________________________________________
			//____________________________________________________________________________________
			// get joint id's
			case .joints:
				joints := [4]u32 {
					u32(fvs[index + 0] + 0.5),
					u32(fvs[index + 1] + 0.5),
					u32(fvs[index + 2] + 0.5),
					u32(fvs[index + 3] + 0.5),
				}

				joints = [4]u32 {
					la.max(u32(0), skin[joints[0]]),
					la.max(u32(0), skin[joints[1]]),
					la.max(u32(0), skin[joints[2]]),
					la.max(u32(0), skin[joints[3]]),
				}

				append(&ids, joints)
			//____________________________________________________________________________________
			//____________________________________________________________________________________

			}
		}


	}


	posCount := len(positions)

	resize(&mesh.vertices, posCount)

	for i: u32 = 0; i < u32(posCount); i += 1 {

		vert: Vertex

		vert.pos = positions[i]

		vert.norm = normals[i]

		if (i < u32(len(uvs))) {
			vert.uv = uvs[i]
		}

		if (i < u32(len(weights))) {
			vert.weights = weights[i]
		}

		if (i < u32(len(ids))) {
			vert.ids = ids[i]
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

@(private = "file")
proccess_channel :: proc(_channel: ^cgltf.animation_channel, targetId: u32, clip: ^Clip) {

	//track: JointTrack

	sampler := _channel.sampler

	if (sampler.interpolation != .linear) {
		fmt.printfln("non linear interpolation!")
		return
	}


	//clip.tracks[targetId].targetId = targetId
	//clip.tracks[targetId].targetName = string(_channel.target_node.name)

	keyframes, values: [dynamic]f32
	get_scalar_values(&keyframes, 1, sampler.input)
	//____________________________________________________________________________________
	//____________________________________________________________________________________
	//compCount := 0
	if _channel.target_path == .translation {
		get_scalar_values(&values, 3, sampler.output)

		//resize(&clip.tracks[targetId].translations, sampler.output.count)
		for i: u32 = 0; i < u32(sampler.output.count); i += 1 {

			index := 3 * i

			clip.tracks[targetId].translations.times = keyframes
			traslations := &clip.tracks[targetId].translations.frames
			translation := [3]f32{values[index + 0], values[index + 1], values[index + 2]}
			append(traslations, translation)

		}

	}
	//____________________________________________________________________________________
	//____________________________________________________________________________________
	if _channel.target_path == .rotation {
		get_scalar_values(&values, 4, sampler.output)

		//resize(&clip.tracks[targetId].rotations, sampler.output.count)
		for i: u32 = 0; i < u32(sampler.output.count); i += 1 {

			index := 4 * i

			clip.tracks[targetId].rotations.times = keyframes
			rotations := &clip.tracks[targetId].rotations.frames
			orientation := quaternion(
				w = values[index + 3],
				x = values[index + 0],
				y = values[index + 1],
				z = values[index + 2],
			)
			append(rotations, orientation)

		}

	}
	//____________________________________________________________________________________
	//____________________________________________________________________________________
	if _channel.target_path == .scale {
		get_scalar_values(&values, 3, sampler.output)

		//resize(&clip.tracks[targetId].scalings, sampler.output.count)
		for i: u32 = 0; i < u32(sampler.output.count); i += 1 {

			index := 3 * i

			clip.tracks[targetId].scalings.times = keyframes
			scalings := &clip.tracks[targetId].scalings.frames
			scaling := [3]f32{values[index + 0], values[index + 1], values[index + 2]}
			append(scalings, scaling)

		}

	}
	//____________________________________________________________________________________
	//____________________________________________________________________________________

	//fmt.printfln("{}", _channel.target_node.name)


}
