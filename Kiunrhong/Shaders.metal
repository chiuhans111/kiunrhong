//
//  Shaders.metal
//  Kiunrhong
//
//

#include <metal_stdlib>
#include "Colors.metal"

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
    // Calculate the relative position, radius, and angle from the view center
    const float2 rel_pos = (vert.position.xy - context->origin);
    const float radius = sqrt(pow(rel_pos.x, 2) + pow(rel_pos.y, 2)) / (min(context->size.x, context->size.y) / 2);
    const float theta = atan2(rel_pos.y, rel_pos.x);
    if (radius > 1.0) return color_t(1, 1, 1, 1);

    // Set up OKLCH parameters
    const float l = 0.6 + (1.0 - 0.6) * (1.0 - radius);
    const float c = 0.168 * radius;
    const float h = (180 + (theta / M_PI_F * 180.0));
    const float3 oklch = float3(l, c, h);
    const float3 color = xyz_to_p3(oklab_to_xyz(oklch_to_oklab(oklch)));
    return color_t(color.x, color.y, color.z, 1.0);
}
