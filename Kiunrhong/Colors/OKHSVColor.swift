//
//  OKHSVColor.swift
//  Kiunrhong
//
//

/// Represents a color in the OKHSV color space.
struct OKHSVColor: Vector3 {

    let h, s, v: Double
    var values: (Double, Double, Double) { (h, s, v) }

    init(_ h: Double, _ s: Double, _ v: Double) {
        self.h = h
        self.s = s
        self.v = v
    }

    static let directionVectorR = (-1.772343927512980392, -0.820758743367406179)
    static let directionVectorG = ( 1.803198717530549774, -1.193281396655892682)
    static let directionVectorB = ( 0.089704878244675408,  1.90327746574161071 )

    func toOKLCH() -> OKLCHColor {
        let a = cos(self.h * .pi / 180.0)
        let b = sin(self.h * .pi / 180.0)

        let lMax, cMax = findCusp(a, b)
        let sMax = cMax / lMax
        let tMax = cMax / (1.0 - lMax)
        let s0 = 0.5
        let k = 1 - s0 / sMax

        // Compute (l, v) as if it’s a triangle
        // L, C when v = 1
        let l_v = 1.0 - self.s * s0 / (s0 + tMax - tMax * k * self.s)
        let c_v = self.s * tMax * s0 / (s0 + tMax - tMax * k * self.s)

        // Compensate for the upper curve and lower toe
        let l_vt = toe_inv(l_v)
        let c_vt = c_v * l_vt / l_v

        let l = l * l_v
        let c = c * c_v

        let l_new = toe_inv(l)
        let c_new = c * l_new / l

        // Scale L?
        let scale = OKLabColor(l_vt, a * c_vt, b * c_vt).toLinearP3()
        let scale_l = cbrt(1.0 / max(max(scale.r, scale.g), max(scale.b, 0.0)))

        return .init(l * scale_l, c * scale_l, self.h)
    }
}

extension OKLabColor {
    func toOKHSV() -> OKHSVColor {
        let oklch = self.toOKLCH()
        let a_ = self.a / oklch.c
        let b_ = self.b / oklch.c

        let l_max, c_max = findCusp(a_, b_)
        let s_max = c_max / l_max
        let t_max = c_max / (1.0 - l_max)
        let s0 = 0.5
        let k = 1 - 0.5 / s_max

        // Find vt values
        let t = t_max / (oklch.c + self.l * t_max)
        let l_v = t * self.l
        let c_v = t * oklch.c

        let l_vt = toe_inv(l_v)
        let c_vt = c_v * l_vt / l_v

        let scale = OKLabColor(l_vt, a_ * c_vt, b * c_vt).toLinearP3()
        let scale_l = cbrt(1.0 / max(max(scale.r, scale.g), max(scale.b, 0.0)))

        let l = self.l / scale_l
        let c = oklch.c / scale_l

        let l_new = toe(l)
        let c_new = c * l_new / l

        let v = l / l_v
        let s = (s0 + t_max) * c_v / ((t_max * s0) + t_max + k * c_v)

        return OKHSVColor(oklch.h, s, v)
    }
}

static func computeMaxSaturation(a: Double, b: Double) -> Double {
    let k0, k1, k2, k3, k4, wl, wm, ws = (
        if (OKHSVColor.directionVectorR.0 * a + OKHSVColor.directionVectorR.1 * b) > 1.0 {
            (1.19086277, 1.76576728, 0.59662641, 0.75515197, 0.56771245, 4.0767416621, -3.3077115913, 0.2309699292)
        } else if (OKHSVColor.directionVectorG.0 * a + OKHSVColor.directionVectorG.1 * b) > 1.0 {
            (0.73956515, -0.45954404, 0.08285427, 0.12541070, 0.14503204, -1.2684380046, 2.6097574011, -0.3413193965)
        } else {
            (1.35733652, -0.00915799, -1.15130210, -0.50559606, 0.00692167, -0.0041960863, -0.7034186147, 1.7076147010)
        })

    // Polynominal approximation
    let s = k0 + k1 * a + k2 * b + k3 * a * a + k4 * a * b

    // One-step Halley's (error < 10^-6)
    let k_lms = GenericColor(
        0.3963377773761749 * a + 0.2158037573099136 * b,
        -0.1055613458156586 * a - 0.0638541728258133 * b
        -0.0894841775298119 * a - 1.2914855480194092 * b)

    let lms_ = GenericColor(1.0, 1.0, 1.0) + k_lms * s
    let lms = lms_ ** 3
    let lms_ds = k_lms * lms_ * lms_ * 3.0
    let lms_ds2 = k_lms * k_lms * lms_ * 6.0

    let w = GenericColor(wl, wm, ws)
    let f = w .* lms
    let f1 = w .* lms_ds
    let f2 = w .* lms_ds2

    return s - f * f1 / (f1 * f1 - 0.5 * f * f2)
}

static func findCusp(a: Double, b: Double) -> (Double, Double) {
    let s_cusp = computeMaxSaturation(a, b)

    let rgb_at_max = OKLabColor(1.0, s_cusp * a, s_cusp * b)
    let l_cusp = cbrt(1.0 / max(max(scale.r, scale.g), max(scale.b, 0.0)))
    let c_cusp = l_cusp * s_cusp

    return (l_cusp, c_cusp)
}
