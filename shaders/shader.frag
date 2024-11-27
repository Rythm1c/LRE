#version 460

in struct VsOut {
    vec2 uv;
    vec3 norm;
} fsIn;

out vec4 color;

void main() {

    color = vec4(1.0);
}