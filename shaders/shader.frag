#version 460

in VsOut {
    vec2 uv;
    vec3 norm;
    vec3 fragPos;
} fsIn;

uniform vec3 inCol;
uniform vec3 lDir;
out vec4 color;

uniform bool textured;
uniform sampler2D tex;

uniform bool enableGrid;
uniform int gridCount;
float grid(int nLines, vec2 uv);

void main() {
    vec3 result = vec3(0.0);

    vec3 finalColor = vec3(1.0);
    if(textured) {
        finalColor = vec3(texture(tex, fsIn.uv));
    } else {
        finalColor = inCol;
    }

    if(enableGrid) {
        if(grid(gridCount, fsIn.uv) == 0.0) {
            finalColor *= 0.15;
        }

    }

    vec3 ambient = 0.15 * finalColor;
    result += ambient;

    vec3 norm = normalize(fsIn.norm);
    vec3 lightDir = normalize(-lDir);
    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = diff * finalColor;
    result += diffuse;

    color = vec4(result, 1.0);
}

float grid(int nLines, vec2 uv) {
    float pos = 1.0 / float(nLines);
    float x = fract(uv.x / pos);
    float y = fract(uv.y / pos);

    vec2 e = vec2(0.005); // edge
    vec2 step1 = step(e, vec2(x, y));
    vec2 step2 = step(e, 1.0 - vec2(x, y));

    return step1.x * step1.y * step2.x * step2.y;

}