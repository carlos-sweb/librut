const std = @import("std");
const rutDv = @import("rut").rutDv;

test "rutDv 16521526 -> 5" {
    try std.testing.expectEqual(@as(u8, '5'), rutDv("16521526"));
}

test "rutDv 30686957 -> 4" {
    try std.testing.expectEqual(@as(u8, '4'), rutDv("30686957"));
}

test "rutDv 12345678 -> 5" {
    try std.testing.expectEqual(@as(u8, '5'), rutDv("12345678"));
}

test "rutDv single digit 1 -> 9" {
    try std.testing.expectEqual(@as(u8, '9'), rutDv("1"));
}

test "rutDv single digit 0 -> 0 (dv 11)" {
    try std.testing.expectEqual(@as(u8, '0'), rutDv("0"));
}

test "rutDv 16521529 -> K (dv 10)" {
    try std.testing.expectEqual(@as(u8, 'K'), rutDv("16521529"));
}

test "rutDv 123456 -> 0 (dv 11)" {
    try std.testing.expectEqual(@as(u8, '0'), rutDv("123456"));
}
