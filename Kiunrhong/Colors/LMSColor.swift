struct LMSColor: Vector3 {

    let l, m, s: Double
    var values: (Double, Double, Double) { (l, m, s) }

    init(_ l: Double, _ m: Double, _ s: Double) {
        self.l = l
        self.m = m
        self.s = s
    }

    static let lmsToXYZ = Matrix3x3(
        ( 1.2268798758459243, -0.5578149944602171,  0.2813910456659647),
        (-0.0405757452148008,  1.1122868032803170, -0.0717110580655164),
        (-0.0763729366746601, -0.4214933324022432,  1.5869240198367816))

    static let lmsToLinearP3 = Matrix3x3(
        ( 3.532009262360754999, -2.14737048882625372 , -0.23799722443865635 ),
        (-1.02637567211677493 ,  2.003841959916313319, -0.02600148518434724 ),
        ( 0.216072997242101285, -0.792698440795908407,  1.539301593034464826))

    func toXYZ() -> XYZColor {
        (self * LMSColor.lmsToXYZ).cast()
    }

    func toLinearP3() -> RGBColor {
        (self * LMSColor.lmsToLinearP3).cast()
    }
}
