#version 460

in VsOut {
    vec2 uv;
    vec3 norm;
    vec3 fragPos;
} fsIn;

uniform vec3 inCol;
uniform vec3 lDir;
out vec4 color;

void main() {
    vec3 result = vec3(0.0);

    vec3 ambient = vec3(0.15) * inCol;
    result += ambient;

    vec3 norm = normalize(fsIn.norm);
    vec3 lightDir = normalize(-lDir);
    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = diff * inCol;
    result += diffuse;

    color = vec4(result,1.0);
}