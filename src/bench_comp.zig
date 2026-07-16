const std = @import("std");
const RUT = @import("rut").RUT;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const stdout_file = std.Io.File.stdout();

    const begin: u32 = 1_000_000;
    const end: u32 = 99_999_999;

    var out_buf: [30]u8 = undefined;

    const time_begin = std.Io.Timestamp.now(io, .awake);

    var i = begin;
    while (i < end) : (i += 1) {
        const rut = RUT.fromNumber(i);
        _ = rut.formatToBuf(&out_buf, ".", "-");
    }

    const time_end = std.Io.Timestamp.now(io, .awake);
    const duration = time_begin.durationTo(time_end);
    const duration_ms = duration.toMilliseconds();

    var buf: [80]u8 = undefined;
    const msg = std.fmt.bufPrint(&buf, "Computation only: {d} ms (~{d} ops/sec)\n", .{ duration_ms, (@as(u64, end) - begin) *| 1000 / @as(u64, @intCast(@max(duration_ms, 1))) }) catch return;
    try std.Io.File.writeStreamingAll(stdout_file, io, msg);
}
