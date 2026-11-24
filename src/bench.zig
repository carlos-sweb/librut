const std = @import("std");
const rutDv = @import("rut").rutDv;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const stdout_file = std.Io.File.stdout();

    const begin: u32 = 16_521_526;
    const end: u32 = 17_521_526; // 1M RUTs with stdout

    var num_buf: [10]u8 = undefined;
    var write_buf: [4096]u8 = undefined;
    var writer_pos: usize = 0;

    const time_begin = std.Io.Clock.now(.awake, io);

    var i = begin;
    while (i < end) : (i += 1) {
        const s = std.fmt.bufPrint(&num_buf, "{d}", .{i}) catch unreachable;
        const dv = rutDv(s);

        @memcpy(write_buf[writer_pos .. writer_pos + s.len], s);
        writer_pos += s.len;
        write_buf[writer_pos] = '-';
        write_buf[writer_pos + 1] = dv;
        write_buf[writer_pos + 2] = '\n';
        writer_pos += 3;

        if (writer_pos >= write_buf.len - 16) {
            try stdout_file.writeStreamingAll(io, write_buf[0..writer_pos]);
            writer_pos = 0;
        }
    }

    if (writer_pos > 0) {
        try stdout_file.writeStreamingAll(io, write_buf[0..writer_pos]);
    }

    const time_end = std.Io.Clock.now(.awake, io);
    const elapsed_ms: f64 = @as(f64, @floatFromInt(time_end.nanoseconds - time_begin.nanoseconds)) / 1_000_000.0;

    var buf: [80]u8 = undefined;
    const msg = try std.fmt.bufPrint(&buf, "Execution time: {d:.2} ms\n", .{elapsed_ms});
    try stdout_file.writeStreamingAll(io, msg);
}
