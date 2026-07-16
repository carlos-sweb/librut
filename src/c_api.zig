const rut = @import("rut");
const RUT = rut.RUT;

export fn rut_calculate_dv(rut_value: u32) callconv(.c) u8 {
    var buf: [10]u8 = undefined;
    const s = std.fmt.bufPrint(&buf, "{d}", .{rut_value}) catch return 0;
    return RUT.calculateDV(s);
}

export fn rut_get_digit_str(rut_value: u32) callconv(.c) u8 {
    const dv = rut_calculate_dv(rut_value);
    return switch (dv) {
        10 => 'k',
        11 => '0',
        else => '0' + dv,
    };
}

export fn rut_check_dv(rut_value: u32, expected: u8) callconv(.c) bool {
    const computed = rut_calculate_dv(rut_value);
    const expected_dv = if (expected == 'k' or expected == 'K') 10 else expected - '0';
    return computed == expected_dv;
}

const std = @import("std");
