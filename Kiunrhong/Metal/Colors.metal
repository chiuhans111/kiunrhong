//
//  Colors.metal
//  Kiunrhong
//
// Color conversion functions reimplemented in Metal.
// Values adapted from W3C CSS Color Module spec.
//

#include <metal_stdlib>
using namespace metal;

constant float3x3 oklab_to_lms = {{1.0,  0.3963377773761749,  0.2158037573099136},
                                  {1.0, -0.1055613458156586, -0.0638541728258133},
                                  {1.0, -0.0894841775298119, -1.2914855480194092}};

constant float3x3 lms3_to_xyz = {{ 1.2268798758459243, -0.5578149944602171,  0.2813910456659647},
                                 {-0.0405757452148008,  1.1122868032803170, -0.0717110580655164},
                                 {-0.0763729366746601, -0.4214933324022432,  1.5869240198367816}};

constant float3x3 xyz_to_linear_p3 = {{446124.0 / 178915.0, -333277.0 / 357830.0, -72051.0 / 178915.0},
                                      {-14852.0 /  17905.0,   63121.0 /  35810.0,    423.0 /  17905.0},
                                      { 11844.0 / 330415.0,  -50337.0 / 660830.0, 316169.0 / 330415.0}};

inline float3 oklch_to_oklab(float3 oklch) {
    const float rad_h = oklch.z * M_PI_F / 180.0;
    return float3(oklch.x, oklch.y * cos(rad_h), oklch.y * sin(rad_h));
}

inline float3 oklab_to_xyz(float3 oklab) {
    const float3 lms = oklab * oklab_to_lms;
    const float3 lms3 = float3(pow(lms.x, 3), pow(lms.y, 3), pow(lms.z, 3));
    return lms3 * lms3_to_xyz;
}

inline float gamma_correct(float c) {
    const float abs_c = abs(c);
    if (abs_c <= 0.0031308) return c * 12.92;
    const float v = 1.055 * pow(abs_c, 1.0 / 2.4) - 0.055;
    return (c >= 0) ? v : -v;
}

inline float3 xyz_to_p3(float3 xyz) {
    const float3 linear_p3 = xyz * xyz_to_linear_p3;
    return float3(gamma_correct(linear_p3.x), gamma_correct(linear_p3.y), gamma_correct(linear_p3.z));
}
