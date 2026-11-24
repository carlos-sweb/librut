const std = @import("std");
const rut = @import("rut");

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
        var digits_buf: [12]u8 = undefined;
        const body = extractBodyDigits(raw, &digits_buf);
        const dv_char = rut.rutDv(body);
        const dv_slice = [1]u8{dv_char};

        if (check_digit_value) |dv_check| {
            const valid = dv_check.len == 1 and ((dv_check[0] >= '0' and dv_check[0] <= '9') or dv_check[0] == 'k' or dv_check[0] == 'K');
            if (!valid) {
                try std.Io.File.writeStreamingAll(stdout_file, io, "Use a valid digit => 0-9 or \"k\" letter\n");
            }
            const check = dv_check.len == 1 and (std.ascii.toUpper(dv_check[0]) == dv_char);
            if (check) {
                try std.Io.File.writeStreamingAll(stdout_file, io, "Check digit => \x1b[32mOk\x1b[00m\n");
            } else {
                var buf: [64]u8 = undefined;
                const msg = std.fmt.bufPrint(&buf, "Check digit => {s} \x1b[31mError\x1b[00m\n", .{dv_check}) catch return;
                try std.Io.File.writeStreamingAll(stdout_file, io, msg);
            }
        }

        if (!get_digit_flag) {
            var fmt_buf: [64]u8 = undefined;
            const formatted = formatRut(&fmt_buf, body, dv_char, separate_miles, separate_digit);
            try std.Io.File.writeStreamingAll(stdout_file, io, formatted);
            try std.Io.File.writeStreamingAll(stdout_file, io, "\n");
        } else {
            try std.Io.File.writeStreamingAll(stdout_file, io, &dv_slice);
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
            try std.Io.File.writeStreamingAll(stdout_file, io, "Version \"0.3.0\"\n");
        }
    }
}

fn extractBodyDigits(raw: []const u8, out: *[12]u8) []const u8 {
    const dash_pos = std.mem.lastIndexOf(u8, raw, "-");
    const body_end = dash_pos orelse raw.len;
    var len: usize = 0;
    for (raw[0..body_end]) |ch| {
        if (ch >= '0' and ch <= '9' and len < out.len) {
            out[len] = ch;
            len += 1;
        }
    }
    return out[0..len];
}

fn formatRut(buf: []u8, body: []const u8, dv_char: u8, sep_miles: []const u8, sep_digit: []const u8) []const u8 {
    var pos: usize = 0;
    for (body, 0..) |ch, idx| {
        if (idx > 0 and ((body.len - idx) % 3 == 0)) {
            @memcpy(buf[pos .. pos + sep_miles.len], sep_miles);
            pos += sep_miles.len;
        }
        buf[pos] = ch;
        pos += 1;
    }
    @memcpy(buf[pos .. pos + sep_digit.len], sep_digit);
    pos += sep_digit.len;
    buf[pos] = dv_char;
    pos += 1;
    return buf[0..pos];
}

fn eqlStr(a: []const u8, b: []const u8) bool {
    return std.mem.eql(u8, a, b);
}
