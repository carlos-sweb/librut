const std = @import("std");
const RUT = @import("rut").RUT;

test "calculateDV 30686957 -> 4" {
    try std.testing.expectEqual(@as(u8, 4), RUT.calculateDV("30686957"));
}

test "calculateDV 12345678 -> 5" {
    try std.testing.expectEqual(@as(u8, 5), RUT.calculateDV("12345678"));
}

test "calculateDV single digit 1 -> 9" {
    try std.testing.expectEqual(@as(u8, 9), RUT.calculateDV("1"));
}

test "calculateDV single digit 0 -> 11" {
    try std.testing.expectEqual(@as(u8, 11), RUT.calculateDV("0"));
}

test "digitToString mapping" {
    try std.testing.expectEqualStrings("k", RUT.digitToString(10));
    try std.testing.expectEqualStrings("0", RUT.digitToString(11));
    try std.testing.expectEqualStrings("0", RUT.digitToString(0));
    try std.testing.expectEqualStrings("5", RUT.digitToString(5));
    try std.testing.expectEqualStrings("9", RUT.digitToString(9));
}

test "fromString with dash separator" {
    const r = RUT.fromString("30686957-4");
    try std.testing.expectEqualStrings("30686957", r.body());
    try std.testing.expect(r.dvInput() != null);
    try std.testing.expectEqualStrings("4", r.dvInput().?);
}

test "fromString without dash" {
    const r = RUT.fromString("30686957");
    try std.testing.expectEqualStrings("30686957", r.body());
    try std.testing.expect(r.dvInput() == null);
}

test "fromString with dots and dash" {
    const r = RUT.fromString("30.686.957-4");
    try std.testing.expectEqualStrings("30686957", r.body());
    try std.testing.expectEqualStrings("4", r.dvInput().?);
}

test "fromString with spaces and dots" {
    const r = RUT.fromString(" 30.686.957-4 ");
    try std.testing.expectEqualStrings("30686957", r.body());
    try std.testing.expect(r.dvInput() != null);
    try std.testing.expectEqualStrings("4", r.dvInput().?);
}

test "fromNumber" {
    const r = RUT.fromNumber(30686957);
    try std.testing.expectEqualStrings("30686957", r.body());
}

test "checkDigit correct" {
    const r = RUT.fromString("30686957-4");
    try std.testing.expect(r.checkDigit("4"));
}

test "checkDigit incorrect" {
    const r = RUT.fromString("30686957-4");
    try std.testing.expect(!r.checkDigit("5"));
}

test "checkDigitWithInput correct" {
    const r = RUT.fromString("30686957-4");
    try std.testing.expect(r.checkDigitWithInput());
}

test "checkDigitWithInput incorrect" {
    const r = RUT.fromString("30686957-5");
    try std.testing.expect(!r.checkDigitWithInput());
}

test "checkDigitWithInput no dv" {
    const r = RUT.fromString("30686957");
    try std.testing.expect(!r.checkDigitWithInput());
}

test "getDigit" {
    const r = RUT.fromString("30686957");
    try std.testing.expectEqualStrings("4", r.getDigit());
}

test "format with dots and dash" {
    const r = RUT.fromString("30686957-4");
    const result = try r.formatAlloc(std.testing.allocator, ".", "-");
    defer std.testing.allocator.free(result);
    try std.testing.expectEqualStrings("30.686.957-4", result);
}

test "format with empty separators" {
    const r = RUT.fromString("30686957-4");
    const result = try r.formatAlloc(std.testing.allocator, "", " ");
    defer std.testing.allocator.free(result);
    try std.testing.expectEqualStrings("30686957 4", result);
}

test "format short rut" {
    const r = RUT.fromString("1-9");
    const result = try r.formatAlloc(std.testing.allocator, ".", "-");
    defer std.testing.allocator.free(result);
    try std.testing.expectEqualStrings("1-9", result);
}

test "format 6 digits" {
    const r = RUT.fromString("123456");
    const result = try r.formatAlloc(std.testing.allocator, ".", "-");
    defer std.testing.allocator.free(result);
    try std.testing.expectEqualStrings("123.456-0", result);
}

test "modulo 11 edge case: dv = 10 (k)" {
    var found = false;
    var n: u32 = 10000000;
    while (n < 20000000) : (n += 1) {
        var buf: [10]u8 = undefined;
        const s = std.fmt.bufPrint(&buf, "{d}", .{n}) catch continue;
        if (RUT.calculateDV(s) == 10) {
            found = true;
            const r = RUT.fromNumber(n);
            try std.testing.expectEqualStrings("k", r.getDigit());
            break;
        }
    }
    try std.testing.expect(found);
}

test "modulo 11 edge case: dv = 11 (0)" {
    var found = false;
    var n: u32 = 10000000;
    while (n < 20000000) : (n += 1) {
        var buf: [10]u8 = undefined;
        const s = std.fmt.bufPrint(&buf, "{d}", .{n}) catch continue;
        if (RUT.calculateDV(s) == 11) {
            found = true;
            const r = RUT.fromNumber(n);
            try std.testing.expectEqualStrings("0", r.getDigit());
            break;
        }
    }
    try std.testing.expect(found);
}

test "full roundtrip: format then parse" {
    const original = RUT.fromString("30686957-4");
    const formatted = try original.formatAlloc(std.testing.allocator, ".", "-");
    defer std.testing.allocator.free(formatted);

    const reparsed = RUT.fromString(formatted);
    try std.testing.expectEqualStrings("30686957", reparsed.body());
    try std.testing.expectEqualStrings("4", reparsed.dvInput().?);
    try std.testing.expect(reparsed.checkDigitWithInput());
}
