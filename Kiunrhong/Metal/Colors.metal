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
    {  3.532009262360754999, -2.14737048882625372 , -0.23799722443865635  },
    { -1.02637567211677493 ,  2.003841959916313319, -0.02600148518434724  },
    {  0.216072997242101285, -0.792698440795908407,  1.539301593034464826 }};

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
    if (abs_c <= 0.0031308) return c * 12.92;
    const float v = 1.055 * pow(abs_c, 1.0 / 2.4) - 0.055;
    return (c >= 0) ? v : -v;
}

inline float3 linear_p3_to_display_p3(float3 linear_p3) {
    return float3(gamma_correct(linear_p3.x), gamma_correct(linear_p3.y), gamma_correct(linear_p3.z));
}
