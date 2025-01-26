#version 460

layout(location = 0) in vec3 pos;
layout(location = 1) in vec3 norm;
layout(location = 2) in vec2 tc;
layout(location = 3) in vec4 weights;
layout(location = 4) in ivec4 boneIds;

uniform mat4 model;
uniform mat4 view;
uniform mat4 proj;
uniform mat4 lightSpace;

out VsOut {
    vec2 uv;
    vec3 norm;
    vec3 fragPos;
} vsOut;

const int MAX_BONES = 300;
const int MAX_BONE_INFLUENCE = 4;
uniform mat4 boneMats[MAX_BONES];

void main() {

    mat4 skin = boneMats[boneIds[0]] * weights[0];
    skin += boneMats[boneIds[1]] * weights[1];
    skin += boneMats[boneIds[2]] * weights[2];
    skin += boneMats[boneIds[3]] * weights[3];

    mat4 final_mat = model * skin;
    gl_Position = proj * view * final_mat * vec4(pos, 1.0);

    vsOut.norm = mat3(transpose(inverse(final_mat))) * norm;
    vsOut.uv = tc;

    vsOut.fragPos = vec3(model * vec4(pos, 1.0));
   // vs_out.lightSpace=lightSpace;

}
