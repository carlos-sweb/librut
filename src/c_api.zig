const rut = @import("rut");
const RUT = rut.RUT;

export fn rut_calculate_dv(rut_value: u32) callconv(.c) u8 {
    return RUT.calculateDVFromNumber(rut_value);
}

export fn rut_calculate_dv_str(digits: [*]const u8, len: usize) callconv(.c) u8 {
    return RUT.calculateDVClean(digits[0..len]);
}

export fn rut_get_digit_str(rut_value: u32) callconv(.c) u8 {
    return RUT.digitToChar(RUT.calculateDVFromNumber(rut_value));
}

export fn rut_get_digit_from_str(digits: [*]const u8, len: usize) callconv(.c) u8 {
    return RUT.digitToChar(RUT.calculateDVClean(digits[0..len]));
}

export fn rut_check_dv(rut_value: u32, expected: u8) callconv(.c) bool {
    const computed = RUT.calculateDVFromNumber(rut_value);
    const expected_dv: u8 = if (expected == 'k' or expected == 'K')
        10
    else if (expected == '0')
        11
    else
        expected - '0';
    return computed == expected_dv;
}
