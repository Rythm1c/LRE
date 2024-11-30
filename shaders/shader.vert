#version 460

layout(location = 0) in vec3 pos;
layout(location = 1) in vec3 norm;
layout(location = 2) in vec2 uv;

out VsOut {
    vec2 uv;
    vec3 norm;
    vec3 fragPos;
} vsOut;

uniform mat4 model;
uniform mat4 view;
uniform mat4 proj;

void main() {

    gl_Position = proj * view * model * vec4(pos, 1.0);
    vsOut.uv = uv;
    vsOut.norm = mat3(transpose(inverse(model))) * norm;
    vsOut.fragPos = vec3(model * vec4(pos, 1.0));
}