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

    pub fn fromNumber(value: u32) RUT {
        var buf: [10]u8 = undefined;
        const s = std.fmt.bufPrint(&buf, "{d}", .{value}) catch return .{
            .body_digits = std.mem.zeroes([12]u8),
            .body_len = 0,
            .dv_input_start = 0,
            .dv_input_len = 0,
        };
        var result: RUT = .{
            .body_digits = std.mem.zeroes([12]u8),
            .body_len = 0,
            .dv_input_start = 0,
            .dv_input_len = 0,
        };
        const copy_len: u8 = @intCast(@min(s.len, 12));
        @memcpy(result.body_digits[0..copy_len], s[0..copy_len]);
        result.body_len = copy_len;
        return result;
    }

    pub fn calculateDV(bodyDigits: []const u8) u8 {
        var total: u32 = 0;
        var factor: u8 = 2;
        var i = bodyDigits.len;
        while (i > 0) {
            i -= 1;
            const ch = bodyDigits[i];
            if (ch < '0' or ch > '9') continue;
            const digit = ch - '0';
            total += @as(u32, digit) * @as(u32, factor);
            factor = if (factor == 7) 2 else factor + 1;
        }
        const remainder: u8 = @intCast(total % 11);
        return 11 - remainder;
    }

    pub fn digitToChar(dv: u8) u8 {
        return switch (dv) {
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
        return digitToString(calculateDV(self.body()));
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
        const dv = self.getDigit();
        var pos: usize = 0;

        for (b, 0..) |ch, idx| {
            if (idx > 0 and ((b.len - idx) % 3 == 0)) {
                for (sep_miles) |s| {
                    buf[pos] = s;
                    pos += 1;
                }
            }
            buf[pos] = ch;
            pos += 1;
        }

        for (sep_digit) |ch| {
            buf[pos] = ch;
            pos += 1;
        }
        for (dv) |ch| {
            buf[pos] = ch;
            pos += 1;
        }
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
