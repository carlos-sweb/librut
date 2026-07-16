const std = @import("std");
const RUT = @import("rut").RUT;
const Io = std.Io;

pub fn main(init: std.process.Init) !void {
    var it = init.minimal.args.iterate();
    defer it.deinit();

    var parser_value: ?[]const u8 = null;
    var check_digit_value: ?[]const u8 = null;
    var get_digit_flag = false;
    var separate_miles: []const u8 = ".";
    var separate_digit: []const u8 = "-";
    var show_help = false;
    var show_version = false;

    _ = it.next();
    while (it.next()) |arg| {
        if (eqlStr(arg, "-p") or eqlStr(arg, "--parser")) {
            if (it.next()) |next_arg| parser_value = next_arg;
        } else if (eqlStr(arg, "--check-digit")) {
            if (it.next()) |next_arg| check_digit_value = next_arg;
        } else if (eqlStr(arg, "--get-digit")) {
            get_digit_flag = true;
        } else if (eqlStr(arg, "--separate-miles")) {
            if (it.next()) |next_arg| separate_miles = next_arg;
        } else if (eqlStr(arg, "--separate-digit")) {
            if (it.next()) |next_arg| separate_digit = next_arg;
        } else if (eqlStr(arg, "-h") or eqlStr(arg, "--help")) {
            show_help = true;
        } else if (eqlStr(arg, "-v") or eqlStr(arg, "--version")) {
            show_version = true;
        }
    }

    const io = init.io;
    const stdout_file = std.Io.File.stdout();

    if (parser_value) |raw| {
        const rut = RUT.fromString(raw);

        if (check_digit_value) |dv_check| {
            const valid_digits = [_][]const u8{ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "k" };
            var valid = false;
            for (valid_digits) |vd| {
                if (eqlStr(dv_check, vd)) {
                    valid = true;
                    break;
                }
            }
            if (!valid) {
                try std.Io.File.writeStreamingAll(stdout_file, io, "Use a valid digit => 0-9 or \"k\" letter\n");
            }
            const check = rut.checkDigit(dv_check);
            if (check) {
                try std.Io.File.writeStreamingAll(stdout_file, io, "Check digit => \x1b[32mOk\x1b[00m\n");
            } else {
                var buf: [64]u8 = undefined;
                const msg = std.fmt.bufPrint(&buf, "Check digit => {s} \x1b[31mError\x1b[00m\n", .{dv_check}) catch return;
                try std.Io.File.writeStreamingAll(stdout_file, io, msg);
            }
        }

        if (!get_digit_flag) {
            const formatted = try rut.formatAlloc(init.arena.allocator(), separate_miles, separate_digit);
            try std.Io.File.writeStreamingAll(stdout_file, io, formatted);
            try std.Io.File.writeStreamingAll(stdout_file, io, "\n");
        } else {
            const d = rut.getDigit();
            try std.Io.File.writeStreamingAll(stdout_file, io, d);
            try std.Io.File.writeStreamingAll(stdout_file, io, "\n");
        }
    } else {
        if (show_help) {
            try std.Io.File.writeStreamingAll(stdout_file, io,
                \\ Usage: rut [OPTIONS]
                \\
                \\ Options:
                \\ -p,--parser: <RUT>          string rut to check
                \\ --check-digit:              digit to compare
                \\ --get-digit:                get only digit verifier
                \\ --separate-miles:           string to separate miles default .
                \\ --separate-digit:           string to separate digit default -
                \\ -v,--version:               show version
                \\ -h,--help:                  show this help
                \\
            );
        }
        if (show_version) {
            try std.Io.File.writeStreamingAll(stdout_file, io, "Version \"0.2.0\"\n");
        }
    }
}

fn eqlStr(a: []const u8, b: []const u8) bool {
    return std.mem.eql(u8, a, b);
}
