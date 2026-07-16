const std = @import("std");
const RUT = @import("rut").RUT;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const stdout_file = std.Io.File.stdout();

    const begin: u32 = 1_000_000;
    const end: u32 = 99_999_999;

    var out_buf: [30]u8 = undefined;
    var write_buf: [4096]u8 = undefined;
    var writer_pos: usize = 0;

    const time_begin = std.Io.Timestamp.now(io, .awake);

    var i = begin;
    while (i < end) : (i += 1) {
        const rut = RUT.fromNumber(i);
        const formatted = rut.formatToBuf(&out_buf, ".", "-");

        for (formatted) |ch| {
            write_buf[writer_pos] = ch;
            writer_pos += 1;
        }
        write_buf[writer_pos] = '\n';
        writer_pos += 1;

        if (writer_pos >= write_buf.len - 30) {
            try std.Io.File.writeStreamingAll(stdout_file, io, write_buf[0..writer_pos]);
            writer_pos = 0;
        }
    }

    if (writer_pos > 0) {
        try std.Io.File.writeStreamingAll(stdout_file, io, write_buf[0..writer_pos]);
    }

    const time_end = std.Io.Timestamp.now(io, .awake);
    const duration = time_begin.durationTo(time_end);
    const duration_ms = duration.toMilliseconds();

    var buf: [80]u8 = undefined;
    const msg = std.fmt.bufPrint(&buf, "Execution time {d} ms\n", .{duration_ms}) catch return;
    try std.Io.File.writeStreamingAll(stdout_file, io, msg);
}
