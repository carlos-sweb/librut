const rut = @import("rut");

export fn rut_dv(s: [*]const u8, len: usize) callconv(.c) u8 {
    return rut.rutDv(s[0..len]);
}
