//
//  Shaders.metal
//  ChromaPlayground
//
//

#include <metal_stdlib>
using namespace metal;

typedef float4 coord_t;
typedef float4 color_t;

struct vertex_t {
    coord_t position [[position]];
};

vertex vertex_t vertexShader(constant vertex_t *vertices [[buffer(0)]], uint i [[vertex_id]]) {
    return vertices[i];
}

fragment color_t fragmentShader(vertex_t vert [[stage_in]]) {
    return color_t(0.5, 0.6, 0.7, 1.0);
}
