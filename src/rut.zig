const std = @import("std");

pub const RUT = struct {
    body_digits: [12]u8,
    body_len: u8,
    dv_input_start: u8,
    dv_input_len: u8,

    pub fn body(self: *const RUT) []const u8 {
        return self.body_digits[0..self.body_len];
    }

    pub fn dvInput(self: *const RUT) ?[]const u8 {
        if (self.dv_input_len == 0) return null;
        return self.body_digits[self.dv_input_start..][0..self.dv_input_len];
    }

    pub fn fromString(raw: []const u8) RUT {
        var result: RUT = .{
            .body_digits = std.mem.zeroes([12]u8),
            .body_len = 0,
            .dv_input_start = 0,
            .dv_input_len = 0,
        };
        const dash_pos = std.mem.lastIndexOf(u8, raw, "-");
        const body_end = dash_pos orelse raw.len;

        var len: u8 = 0;
        for (raw[0..body_end]) |ch| {
            if (ch >= '0' and ch <= '9') {
                if (len < 12) {
                    result.body_digits[len] = ch;
                    len += 1;
                }
            }
        }
        result.body_len = len;

        if (dash_pos) |dp| {
            const dv_start = dp + 1;
            if (dv_start < raw.len) {
                const dv_part = std.mem.trim(u8, raw[dv_start..], " ");
                if (dv_part.len > 0) {
                    for (dv_part, 0..) |dch, di| {
                        if (len + di < 12) {
                            result.body_digits[len + di] = dch;
                        }
                    }
                    result.dv_input_start = len;
                    result.dv_input_len = @intCast(@min(dv_part.len, 12 - len));
                }
            }
        }
        return result;
    }

    const digits2 = "00010203040506070809101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960616263646566676869707172737475767778798081828384858687888990919293949596979899";

    pub fn fromNumber(value: u32) RUT {
        var result: RUT = .{
            .body_digits = undefined,
            .body_len = 0,
            .dv_input_start = 0,
            .dv_input_len = 0,
        };
        if (value == 0) {
            result.body_digits[0] = '0';
            result.body_len = 1;
            return result;
        }
        var tmp: [10]u8 = undefined;
        var pos: usize = 10;
        var n = value;
        while (n >= 100) {
            const idx: usize = @intCast((n % 100) * 2);
            n /= 100;
            pos -= 2;
            tmp[pos] = digits2[idx];
            tmp[pos + 1] = digits2[idx + 1];
        }
        if (n >= 10) {
            const idx: usize = @intCast(n * 2);
            pos -= 2;
            tmp[pos] = digits2[idx];
            tmp[pos + 1] = digits2[idx + 1];
        } else {
            pos -= 1;
            tmp[pos] = @as(u8, @intCast(n)) + '0';
        }
        const copy_len: u8 = @intCast(10 - pos);
        @memcpy(result.body_digits[0..copy_len], tmp[pos..10]);
        result.body_len = copy_len;
        return result;
    }

    pub fn calculateDVFromNumber(value: u32) u8 {
        var n = value;
        var total: u32 = 0;
        var factor: u32 = 2;
        while (n > 0) {
            const digit = n % 10;
            n /= 10;
            total += digit * factor;
            factor = if (factor == 7) 2 else factor + 1;
        }
        const remainder: u8 = @intCast(total % 11);
        return 11 - remainder;
    }

    /// Fast DV calculation for pre-sanitized ASCII digit slices ('0'..'9').
    /// Scans right-to-left with zero division by 10 and no non-digit branching.
    pub fn calculateDVClean(bodyDigits: []const u8) u8 {
        var total: u32 = 0;
        var factor: u32 = 2;
        var i = bodyDigits.len;
        while (i > 0) {
            i -= 1;
            total += @as(u32, bodyDigits[i] - '0') * factor;
            factor = if (factor == 7) 2 else factor + 1;
        }
        const remainder: u8 = @intCast(total % 11);
        return 11 - remainder;
    }

    pub fn calculateDV(bodyDigits: []const u8) u8 {
        var total: u32 = 0;
        var factor: u32 = 2;
        var i = bodyDigits.len;
        while (i > 0) {
            i -= 1;
            const ch = bodyDigits[i];
            if (ch < '0' or ch > '9') continue;
            total += @as(u32, ch - '0') * factor;
            factor = if (factor == 7) 2 else factor + 1;
        }
        const remainder: u8 = @intCast(total % 11);
        return 11 - remainder;
    }

    pub fn digitToChar(dv: u8) u8 {
        return switch (dv) {
            11 => '0',
            10 => 'k',
            0...9 => |d| '0' + d,
            else => unreachable,
        };
    }

    pub fn digitToString(dv: u8) []const u8 {
        return switch (dv) {
            11 => "0",
            10 => "k",
            0 => "0",
            1 => "1",
            2 => "2",
            3 => "3",
            4 => "4",
            5 => "5",
            6 => "6",
            7 => "7",
            8 => "8",
            9 => "9",
            else => unreachable,
        };
    }

    pub fn getDigit(self: *const RUT) []const u8 {
        return digitToString(calculateDVClean(self.body()));
    }

    pub fn checkDigit(self: *const RUT, local_digit: []const u8) bool {
        return std.mem.eql(u8, self.getDigit(), local_digit);
    }

    pub fn checkDigitWithInput(self: *const RUT) bool {
        if (self.dvInput()) |dv| {
            return self.checkDigit(dv);
        }
        return false;
    }

    pub fn formatAlloc(self: *const RUT, allocator: std.mem.Allocator, sep_miles: []const u8, sep_digit: []const u8) ![]u8 {
        var buf: [30]u8 = undefined;
        const result = self.formatToBuf(&buf, sep_miles, sep_digit);
        return try allocator.dupe(u8, result);
    }

    pub fn formatToBuf(self: *const RUT, buf: []u8, sep_miles: []const u8, sep_digit: []const u8) []const u8 {
        const b = self.body();
        const dv_char = digitToChar(calculateDVClean(b));
        var pos: usize = 0;

        if (b.len > 0) {
            var next_sep = b.len % 3;
            if (next_sep == 0) next_sep = 3;

            if (sep_miles.len == 1) {
                const sm = sep_miles[0];
                for (b, 0..) |ch, idx| {
                    if (idx == next_sep) {
                        buf[pos] = sm;
                        pos += 1;
                        next_sep += 3;
                    }
                    buf[pos] = ch;
                    pos += 1;
                }
            } else if (sep_miles.len == 0) {
                @memcpy(buf[0..b.len], b);
                pos = b.len;
            } else {
                for (b, 0..) |ch, idx| {
                    if (idx == next_sep) {
                        @memcpy(buf[pos .. pos + sep_miles.len], sep_miles);
                        pos += sep_miles.len;
                        next_sep += 3;
                    }
                    buf[pos] = ch;
                    pos += 1;
                }
            }
        }

        if (sep_digit.len == 1) {
            buf[pos] = sep_digit[0];
            pos += 1;
        } else if (sep_digit.len > 1) {
            @memcpy(buf[pos .. pos + sep_digit.len], sep_digit);
            pos += sep_digit.len;
        }

        buf[pos] = dv_char;
        pos += 1;
        return buf[0..pos];
    }
};

test "calculateDV 30686957" {
    try std.testing.expectEqual(@as(u8, 4), RUT.calculateDV("30686957"));
}

test "calculateDV 12345678" {
    try std.testing.expectEqual(@as(u8, 5), RUT.calculateDV("12345678"));
}

test "calculateDV 1" {
    try std.testing.expectEqual(@as(u8, 9), RUT.calculateDV("1"));
}

test "calculateDV produces 10 -> k" {
    try std.testing.expectEqual(@as(u8, 10), RUT.calculateDV("15470893"));
}

test "calculateDV produces 11 -> 0" {
    var found = false;
    var n: u32 = 0;
    while (n < 100000) : (n += 1) {
        var buf: [10]u8 = undefined;
        const s = std.fmt.bufPrint(&buf, "{d}", .{n}) catch continue;
        if (RUT.calculateDV(s) == 11) {
            found = true;
            break;
        }
    }
    try std.testing.expect(found);
}

test "digitToString" {
    try std.testing.expectEqualStrings("k", RUT.digitToString(10));
    try std.testing.expectEqualStrings("0", RUT.digitToString(11));
    try std.testing.expectEqualStrings("0", RUT.digitToString(0));
    try std.testing.expectEqualStrings("5", RUT.digitToString(5));
}

test "digitToChar" {
    try std.testing.expectEqual(@as(u8, 'k'), RUT.digitToChar(10));
    try std.testing.expectEqual(@as(u8, '0'), RUT.digitToChar(0));
    try std.testing.expectEqual(@as(u8, '5'), RUT.digitToChar(5));
}

test "fromString with dash" {
    const rut = RUT.fromString("30686957-4");
    try std.testing.expectEqualStrings("30686957", rut.body());
    try std.testing.expect(rut.dvInput() != null);
    try std.testing.expectEqualStrings("4", rut.dvInput().?);
}

test "fromString without dash" {
    const rut = RUT.fromString("30686957");
    try std.testing.expectEqualStrings("30686957", rut.body());
    try std.testing.expect(rut.dvInput() == null);
}

test "fromString with dots and dash" {
    const rut = RUT.fromString("30.686.957-4");
    try std.testing.expectEqualStrings("30686957", rut.body());
    try std.testing.expectEqualStrings("4", rut.dvInput().?);
}

test "fromString with spaces and dots" {
    const rut = RUT.fromString(" 30.686.957-4 ");
    try std.testing.expectEqualStrings("30686957", rut.body());
    try std.testing.expectEqualStrings("4", rut.dvInput().?);
}

test "fromNumber" {
    const rut = RUT.fromNumber(30686957);
    try std.testing.expectEqualStrings("30686957", rut.body());
}

test "checkDigit correct" {
    const rut = RUT.fromString("30686957-4");
    try std.testing.expect(rut.checkDigit("4"));
}

test "checkDigit incorrect" {
    const rut = RUT.fromString("30686957-4");
    try std.testing.expect(!rut.checkDigit("5"));
}

test "checkDigitWithInput" {
    const rut = RUT.fromString("30686957-4");
    try std.testing.expect(rut.checkDigitWithInput());
}

test "getDigit" {
    const rut = RUT.fromString("30686957");
    try std.testing.expectEqualStrings("4", rut.getDigit());
}

test "format default" {
    const rut = RUT.fromString("30686957-4");
    const result = try rut.formatAlloc(std.testing.allocator, ".", "-");
    defer std.testing.allocator.free(result);
    try std.testing.expectEqualStrings("30.686.957-4", result);
}

test "format no separators" {
    const rut = RUT.fromString("30686957-4");
    const result = try rut.formatAlloc(std.testing.allocator, "", " ");
    defer std.testing.allocator.free(result);
    try std.testing.expectEqualStrings("30686957 4", result);
}

test "format short rut" {
    const rut = RUT.fromString("1-9");
    const result = try rut.formatAlloc(std.testing.allocator, ".", "-");
    defer std.testing.allocator.free(result);
    try std.testing.expectEqualStrings("1-9", result);
}

test "format 6 digits" {
    const rut = RUT.fromString("123456");
    const result = try rut.formatAlloc(std.testing.allocator, ".", "-");
    defer std.testing.allocator.free(result);
    try std.testing.expectEqualStrings("123.456-0", result);
}
