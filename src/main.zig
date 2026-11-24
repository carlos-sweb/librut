const std = @import("std");
const rut = @import("rut");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const stdout_file = std.Io.File.stdout();

    var it = init.minimal.args.iterate();
    defer it.deinit();
    _ = it.next(); // program name

    var input: ?[]const u8 = null;
    while (it.next()) |arg| {
        if (std.mem.eql(u8, arg, "-h") or std.mem.eql(u8, arg, "--help")) {
            try stdout_file.writeStreamingAll(io,
                \\Usage: rut <DIGITS>
                \\
                \\Receives a clean Chilean RUT body (digits only, no dots or dash)
                \\and prints its check digit ('0'-'9' or 'K').
                \\
                \\Example:
                \\  rut 16521526   -> 5
                \\
            );
            return;
        } else if (std.mem.eql(u8, arg, "-v") or std.mem.eql(u8, arg, "--version")) {
            try stdout_file.writeStreamingAll(io, "librut 0.3.0\n");
            return;
        } else if (std.mem.eql(u8, arg, "-p") or std.mem.eql(u8, arg, "--parser")) {
            input = it.next();
        } else if (input == null) {
            input = arg;
        }
    }

    if (input) |s| {
        const dv = rut.rutDv(s);
        const out = [2]u8{ dv, '\n' };
        try stdout_file.writeStreamingAll(io, &out);
    } else {
        try stdout_file.writeStreamingAll(io, "Usage: rut <DIGITS>\n");
    }
}
