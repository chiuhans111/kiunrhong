//
//  Shaders.metal
//  Kiunrhong
//
//

#include <metal_stdlib>
#include "Colors.metal"

using namespace metal;

typedef float2 point_t;
typedef float2 bound_t;
typedef float4 coord_t;
typedef half4 color_t;

struct vertex_t {
    coord_t position [[position]];
};

struct shader_context {
    /// The size of the currently rendering drawable.
    bound_t drawable_size;

    /// The color parameters used to draw the spectrum.
    color_t color_values;
};

vertex vertex_t vertexShader(constant vertex_t *vertices [[buffer(0)]], uint i [[vertex_id]]) {
    return vertices[i];
}

fragment color_t fragmentShader(vertex_t vert [[stage_in]], constant shader_context *context [[buffer(0)]]) {
    // Loads the data from buffer
    const bound_t size = context->drawable_size;
    const float radius = min(size.x, size.y) / 2.0;

    // Calculate the coordinates and distance relative to the center of the view.
    const float2 position = (vert.position.xy - size / 2.0);
    const float distance = sqrt(pow(position.x, 2) + pow(position.y, 2)) / radius;
    const float angle = atan2(position.y, position.x);

    if (distance > 1.0)
        return color_t(0.0, 0.0, 0.0, 0.0); // Make out-of-circle pixels transparent

    // Calculate the OKLCH colors based on the coordinates
    const float l = 0.6 + (1.0 - 0.6) * (1.0 - distance);
    const float c = 0.168 * distance;
    const float h = (180 + (angle / M_PI_F * 180.0));

    // Convert the color to Display P3 colorspace and render
    const float3 oklch = float3(l, c, h);
    const float3 color = linear_p3_to_display_p3(oklab_to_linear_p3(oklch_to_oklab(oklch)));
    return color_t(color.x, color.y, color.z, 1.0);
}
