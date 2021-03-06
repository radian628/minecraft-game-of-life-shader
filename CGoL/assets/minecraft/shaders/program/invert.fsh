#version 120

uniform sampler2D DiffuseSampler;
uniform sampler2D PrevSampler;

uniform vec2 OutSize;

varying vec2 texCoord;


//CONTRAST EDGE SHADER
vec4 contrastEdge() {
    vec4 sample1 = texture2D(DiffuseSampler, texCoord);
    vec4 sample2 = texture2D(DiffuseSampler, texCoord + vec2(0.0, 1.0 / OutSize.y));
    vec4 sample3 = texture2D(DiffuseSampler, texCoord + vec2(1.0 / OutSize.x, 0.0));
    float diff1 = length(sample1 - sample2);
    float diff2 = length(sample1 - sample3);
    if (diff1 > 0.10 || diff2 > 0.10) {
        return vec4(1.0, 1.0, 1.0, 1.0);
    }
    return vec4(0.0, 0.0, 0.0, 1.0);
}


//CGoL SHADER
vec4 conwayGameOfLife() {
    vec4 cell = texture2D(PrevSampler, texCoord);
    float dx = 1.0 / OutSize.x;
    float dy = 1.0 / OutSize.y;
    vec4 neighbors[8] = vec4[8](
        texture2D(PrevSampler, texCoord + vec2(-dx, -dy)),
        texture2D(PrevSampler, texCoord + vec2(0.0, -dy)),
        texture2D(PrevSampler, texCoord + vec2(dx, -dy)),
        texture2D(PrevSampler, texCoord + vec2(-dx, 0.0)),
        texture2D(PrevSampler, texCoord + vec2(dx, 0.0)),
        texture2D(PrevSampler, texCoord + vec2(-dx, dy)),
        texture2D(PrevSampler, texCoord + vec2(0.0, dy)),
        texture2D(PrevSampler, texCoord + vec2(dx, dy))
    );

    int aliveCount = 0;

    vec4 leastBrightest = vec4(1.0);

    for (int i = 0; i < 8; i++) {
        if (neighbors[i].x > 128.0 / 256.0) {
            aliveCount++;
            if (neighbors[i].x < leastBrightest.x) {
                leastBrightest = neighbors[i];
            }
        }
    }

    vec4 aliveExample = vec4(1.0, 1.0, 1.0, 1.0);
    vec4 deadExample = vec4(0.0, 0.0, 0.0, 1.0);

    vec4 outColor = cell;

    if (aliveCount > 3 || aliveCount < 2) {
        if (cell.x > 128.0 / 256.0) {
            outColor = vec4(vec3(0.49), 1.0);
        }
        outColor = vec4(outColor.xyz - vec3(0.1), 1.0);
    } else if (aliveCount == 3) {
        outColor = leastBrightest;
    } else {
        outColor = vec4(outColor.xyz - vec3(0.01), 1.0);
    }

    return outColor + contrastEdge() * 0.5;

}

void main() {
    gl_FragColor = conwayGameOfLife();
}
