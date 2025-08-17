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


//
//  OKHSV to display p3 extension
//
//  Created by Hans Chiu on 2025/8/17.
//
//  Credit/Reference:
//  https://bottosson.github.io/posts/gamutclipping/
//  https://github.com/bottosson/bottosson.github.io/blob/master/misc/colorpicker/colorconversion.js
//

// Finds the maximum saturation possible for a given hue that fits in display P3
// Saturation here is defined as S = C/L
// a and b must be normalized so a^2 + b^2 == 1
inline float compute_max_saturation(float a, float b)
{
    // Max saturation will be when one of r, g or b goes below zero.
    
    // Select different coefficients depending on which component goes below zero first
    float k0, k1, k2, k3, k4, wl, wm, ws;

    if (-1.768934808792026 * a + -0.8157226373539518 * b > 1)
    {
        // Red component
        k0 = 1.428885889280113f; k1 = 1.9891572888141669f; k2 = 0.7076567944415829f; k3 = 0.8056114450013463f; k4 = 0.6366648916854816f;
        wl = 3.128361639977628; wm = -2.2583188611418157; ws = 0.13047827047835303;
    }
    else if (1.8054363673694167 * a + -1.1997060299599343 * b > 1)
    {
        // Green component
        k0 = 0.7646198863383998f; k1 = -0.4423088429629013f; k2 = 0.10846562973408484f; k3 = 0.1342843898983666f; k4 = -0.16289334043422918f;
        wl = -1.0907196908026295; wm = 2.414304954049877; ws = -0.32372625533207666;
    }
    else
    {
        // Blue component
        k0 = +1.35733652f; k1 = -0.00915799f; k2 = -1.15130210f; k3 = -0.50559606f; k4 = +0.00692167f;
        wl = -0.026030028812136462; wm = -0.508377306338749; ws = 1.534316245321829;
    }

    // Approximate max saturation using a polynomial:
    float S = k0 + k1 * a + k2 * b + k3 * a * a + k4 * a * b;

    // Do one step Halley's method to get closer
    // this gives an error less than 10e6, except for some blue hues where the dS/dh is close to infinite
    // this should be sufficient for most applications, otherwise do two/three steps

    float k_l = +0.3963377774f * a + 0.2158037573f * b;
    float k_m = -0.1055613458f * a - 0.0638541728f * b;
    float k_s = -0.0894841775f * a - 1.2914855480f * b;

    {
        float l_ = 1.f + S * k_l;
        float m_ = 1.f + S * k_m;
        float s_ = 1.f + S * k_s;

        float l = l_ * l_ * l_;
        float m = m_ * m_ * m_;
        float s = s_ * s_ * s_;

        float l_dS = 3.f * k_l * l_ * l_;
        float m_dS = 3.f * k_m * m_ * m_;
        float s_dS = 3.f * k_s * s_ * s_;

        float l_dS2 = 6.f * k_l * k_l * l_;
        float m_dS2 = 6.f * k_m * k_m * m_;
        float s_dS2 = 6.f * k_s * k_s * s_;

        float f  = wl * l     + wm * m     + ws * s;
        float f1 = wl * l_dS  + wm * m_dS  + ws * s_dS;
        float f2 = wl * l_dS2 + wm * m_dS2 + ws * s_dS2;

        S = S - f * f1 / (f1*f1 - 0.5f * f * f2);
    }

    return S;
}

// finds L_cusp and C_cusp for a given hue
// a and b must be normalized so a^2 + b^2 == 1
inline float2 find_cusp(float a, float b)
{
    // First, find the maximum saturation (saturation S = C/L)
    float S_cusp = compute_max_saturation(a, b);

    // Convert to linear sRGB to find the first point where at least one of r,g or b >= 1:
    float3 rgb_at_max = oklab_to_linear_p3(float3( 1, S_cusp * a, S_cusp * b ));
    float L_cusp = pow(1.f / max(max(rgb_at_max.r, rgb_at_max.g), rgb_at_max.b), 1.0/3);
    float C_cusp = L_cusp * S_cusp;

    return float2(L_cusp, C_cusp);
}


inline float3 okhsv_to_linear_p3(float3 hsv)
{
    float h = hsv.x;
    float s = hsv.y;
    float v = hsv.z;
    
    
    float a_ = cos(2*M_PI_F*h/360);
    float b_ = sin(2*M_PI_F*h/360);
    
    
    float2 cusp = find_cusp(a_, b_);
    float L_ = cusp.x;
    float C_ = cusp.y;
    
    
    float S_max = C_/L_;
    float T = C_/(1-L_);
    
    float S_0 = 0.5;
    float k = 1 - S_0/S_max;
    
    float L_v = 1 - s*S_0/(S_0+T - T*k*s);
    float C_v = s*T*S_0/(S_0+T-T*k*s);
        

    float L = v*L_v;
    float C = v*C_v;
    
    // to present steps along the way
    //L = v;
    //C = v*s*S_max;
    //L = v*(1 - s*S_max/(S_max+T));
    //C = v*s*S_max*T/(S_max+T);

    float L_vt = from_relative_l(L_v);
    float C_vt = C_v * L_vt/L_v;
    

    float L_new =  from_relative_l(L); // * L_v/L_vt;
    C = C * L_new/L;
    L = L_new;
    
    float3 rgb_scale = oklab_to_linear_p3(float3(L_vt, a_*C_vt, b_*C_vt));
    
    float scale_L = pow(1/(max(max(rgb_scale.r, rgb_scale.g),
                               max(rgb_scale.b, 0.0)
                               )), 1/3);
    
    // remove to see effect without rescaling
    L = L*scale_L;
    C = C*scale_L;

    float3 rgb = oklab_to_linear_p3(float3(L, C*a_, C*b_));
    return rgb;
}
