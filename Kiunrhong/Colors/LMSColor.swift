struct LMSColor: Vector3 {

    let l, m, s: Double
    var values: (Double, Double, Double) { (l, m, s) }

    init(_ l: Double, _ m: Double, _ s: Double) {
        self.l = l
        self.m = m
        self.s = s
    }

    static let lmsToXYZ = Matrix3x3(
        ( 1.226879875845924,   -0.5578149944602171,   0.2813910456659647),
        (-0.04057574521480083,  1.112286803280317,   -0.07171105806551635),
        (-0.07637293667466008, -0.42149333240224324,  1.5869240198367818))

    static let lmsToLinearP3 = Matrix3x3(
        ( 3.532009262360754446, -2.147370488826253513, -0.23799722443865626),
        (-1.026375672116775014,  2.003841959916313347, -0.026001485184347173),
        ( 0.216072997242101374, -0.792698440795908535,  1.539301593034465032))

    func toXYZ() -> XYZColor {
        (self * LMSColor.lmsToXYZ).cast()
    }

    func toLinearP3() -> RGBColor {
        (self * LMSColor.lmsToLinearP3).cast()
    }
}
