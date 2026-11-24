const std = @import("std");
const rutDv = @import("rut").rutDv;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const gpa = init.gpa;
    const stdout_file = std.Io.File.stdout();

    const count: usize = 1000;
    const passes: usize = 100_000; // 100M RUTs total
    const total_ops: u64 = count * passes;

    var ruts = try gpa.alloc([8]u8, count);
    defer gpa.free(ruts);
    for (0..count) |i| {
        _ = std.fmt.bufPrint(&ruts[i], "{d}", .{16521526 + i}) catch unreachable;
    }

    const time_begin = std.Io.Clock.now(.awake, io);

    var acc: u64 = 0;
    for (0..passes) |_| {
        for (0..count) |i| {
            acc += rutDv(&ruts[i]);
        }
    }

    const time_end = std.Io.Clock.now(.awake, io);
    const elapsed_ns: f64 = @floatFromInt(time_end.nanoseconds - time_begin.nanoseconds);
    const elapsed_ms = elapsed_ns / 1_000_000.0;
    const mops = (@as(f64, @floatFromInt(total_ops)) / (elapsed_ns / 1_000_000_000.0)) / 1_000_000.0;

    var buf: [128]u8 = undefined;
    const msg = try std.fmt.bufPrint(
        &buf,
        "rutDv (100M ops): {d:.2} ms (~{d:.1}M ops/sec, checksum={d})\n",
        .{ elapsed_ms, mops, acc },
    );
    try stdout_file.writeStreamingAll(io, msg);
}
