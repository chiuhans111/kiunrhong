//
//  Shaders.metal
//  ChromaPlayground
//
//

#include <metal_stdlib>
#include <metal_logging>

using namespace metal;

typedef float2 point_t;
typedef float4 coord_t;
typedef half4 color_t;

struct vertex_t {
    coord_t position [[position]];
};

struct shader_context {
    /// The center of the view.
    point_t origin;

    /// The overall size of the view.
    float2 size;
};

vertex vertex_t vertexShader(constant vertex_t *vertices [[buffer(0)]], uint i [[vertex_id]]) {
    return vertices[i];
}

fragment color_t fragmentShader(vertex_t vert [[stage_in]], constant shader_context *context [[buffer(0)]]) {
    float2 rel_pos = (vert.position.xy - context->origin);
    float radius = sqrt(pow(rel_pos.x, 2) + pow(rel_pos.y, 2)) / (min(context->size.x, context->size.y) / 2);
    float theta = atan(rel_pos.y / rel_pos.x);
    return color_t(1 * (1 - radius), 1 * (1 - radius) / (M_PI_F + theta), 1 * (1 - radius) / (M_PI_F + theta), 1.0);
}
