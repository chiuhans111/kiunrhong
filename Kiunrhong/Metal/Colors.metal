//
//  Colors.metal
//  Kiunrhong
//
// Color conversion functions reimplemented in Metal.
// Values adapted from W3C CSS Color Module spec.
//

#include <metal_stdlib>
using namespace metal;

constant float3x3 oklab_to_lms_cbrt = {
    { 1.0,  0.3963377773761749,  0.2158037573099136 },
    { 1.0, -0.1055613458156586, -0.0638541728258133 },
    { 1.0, -0.0894841775298119, -1.2914855480194092 }};

/// Premultiplied LMS – XYZ D65 – Linear P3 conversion matrix for faster processing
constant float3x3 lms_to_linear_p3 = {
    {3.1283616399776282, -2.2583188611418157, 0.1304782704783530},
    {-1.0907196908026295, 2.4143049540498769, -0.3237262553320767},
    {-0.0260300288121365, -0.5083773063387490, 1.5343162453218291}};

inline float3 oklch_to_oklab(float3 oklch) {
    const float rad_h = oklch.z * M_PI_F / 180.0;
    return float3(oklch.x, oklch.y * cos(rad_h), oklch.y * sin(rad_h));
}

inline float3 oklab_to_linear_p3(float3 oklab) {
    const float3 lms_cbrt = oklab * oklab_to_lms_cbrt;
    const float3 lms = float3(pow(lms_cbrt.x, 3), pow(lms_cbrt.y, 3), pow(lms_cbrt.z, 3));
    return lms * lms_to_linear_p3;
}

inline float gamma_correct(float c) {
    const float abs_c = abs(c);
    if (abs_c <= 0.00308) return c * 12.987012987012987;
    const float v = 1.0548523206751055 * powr(abs_c, 1.0 / 2.4) - 0.05485232067510549;
    return copysign(v, c);
}

inline float3 linear_p3_to_display_p3(float3 linear_p3) {
    return float3(gamma_correct(linear_p3.x), gamma_correct(linear_p3.y), gamma_correct(linear_p3.z));
}

inline float to_relative_l(float l) {
    const float k3_l = (1 + 0.206) / (1 + 0.02) * l;
    const float dk = k3_l - 0.206;
    return (dk + sqrt(dk * dk + 4 * 0.03 * k3_l)) / 2;
}

inline float from_relative_l(float lr) {
    const float k3 = (1 + 0.206) / (1 + 0.02);
    return lr * (lr + 0.206) / (k3 * (lr + 0.03));
}
