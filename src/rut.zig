pub fn rutDv(s: []const u8) u8 {
    var m: i64 = 2;
    var t: i64 = 0;
    var i: usize = s.len;
    while (i > 0) {
        i -= 1;
        t += @as(i64, s[i] - '0') * m;
        m = if (m == 7) 2 else m + 1;
    }
    const dv_num = 11 - @mod(t, 11);
    return switch (dv_num) {
        11 => '0',
        10 => 'K',
        else => @intCast('0' + dv_num),
    };
}
