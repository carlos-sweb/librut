const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // ── Modules ──────────────────────────────────────────────
    const rut_mod = b.createModule(.{
        .root_source_file = b.path("src/rut.zig"),
        .target = target,
        .optimize = optimize,
    });

    const c_api_mod = b.createModule(.{
        .root_source_file = b.path("src/c_api.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "rut", .module = rut_mod },
        },
    });

    const main_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "rut", .module = rut_mod },
        },
    });

    const test_mod = b.createModule(.{
        .root_source_file = b.path("src/test_rut.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "rut", .module = rut_mod },
        },
    });

    // ── Static library ───────────────────────────────────────
    const static_lib = b.addLibrary(.{
        .linkage = .static,
        .name = "rut",
        .root_module = rut_mod,
    });
    static_lib.installHeader(b.path("src/rut.zig"), "rut.zig");
    b.installArtifact(static_lib);

    // ── Shared library (C-ABI) ──────────────────────────────
    const shared_lib = b.addLibrary(.{
        .linkage = .dynamic,
        .name = "rut",
        .root_module = c_api_mod,
    });
    b.installArtifact(shared_lib);

    // ── Static library (C-ABI) ─────────────────────────────
    const c_static_lib = b.addLibrary(.{
        .linkage = .static,
        .name = "rut_c",
        .root_module = c_api_mod,
    });
    c_static_lib.installHeader(b.path("include/rut.h"), "rut.h");
    b.installArtifact(c_static_lib);

    // ── Executable ───────────────────────────────────────────
    const exe = b.addExecutable(.{
        .name = "rut",
        .root_module = main_mod,
    });
    b.installArtifact(exe);

    // ── Run step ─────────────────────────────────────────────
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the rut CLI");
    run_step.dependOn(&run_cmd.step);

    // ── Tests ────────────────────────────────────────────────
    const tests = b.addTest(.{
        .root_module = test_mod,
    });
    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_tests.step);

    // ── Benchmark ──────────────────────────────────────────
    const bench_mod = b.createModule(.{
        .root_source_file = b.path("src/bench.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "rut", .module = rut_mod },
        },
    });

    const bench_exe = b.addExecutable(.{
        .name = "bench",
        .root_module = bench_mod,
    });
    b.installArtifact(bench_exe);

    const run_bench = b.addRunArtifact(bench_exe);
    run_bench.step.dependOn(b.getInstallStep());
    const bench_step = b.step("bench", "Run benchmark");
    bench_step.dependOn(&run_bench.step);

    // ── Benchmark (computation only) ───────────────────────
    const bench_comp_mod = b.createModule(.{
        .root_source_file = b.path("src/bench_comp.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "rut", .module = rut_mod },
        },
    });

    const bench_comp_exe = b.addExecutable(.{
        .name = "bench_comp",
        .root_module = bench_comp_mod,
    });
    b.installArtifact(bench_comp_exe);

    const run_bench_comp = b.addRunArtifact(bench_comp_exe);
    run_bench_comp.step.dependOn(b.getInstallStep());
    const bench_comp_step = b.step("bench-comp", "Run benchmark (computation only)");
    bench_comp_step.dependOn(&run_bench_comp.step);

    // ── pkg-config files ────────────────────────────────────
    const wf = b.addWriteFiles();

    const shared_pc = b.fmt(
        \\prefix={s}
        \\libdir=${{prefix}}/lib
        \\includedir=${{prefix}}/include
        \\
        \\Name: librut
        \\Description: Biblioteca para validacion de RUT chileno
        \\Version: 0.2.0
        \\Libs: -L${{libdir}} -lrut
        \\Cflags: -I${{includedir}}
    , .{b.install_prefix});

    const static_pc = b.fmt(
        \\prefix={s}
        \\libdir=${{prefix}}/lib
        \\includedir=${{prefix}}/include
        \\
        \\Name: librut-static
        \\Description: Biblioteca para validacion de RUT chileno (estatica)
        \\Version: 0.2.0
        \\Libs: -L${{libdir}} -lrut_c
        \\Cflags: -I${{includedir}}
    , .{b.install_prefix});

    const shared_pc_file = wf.add("librut.pc", shared_pc);
    const static_pc_file = wf.add("librut-static.pc", static_pc);

    b.getInstallStep().dependOn(
        &b.addInstallFileWithDir(shared_pc_file, .{ .custom = "lib/pkgconfig" }, "librut.pc").step,
    );
    b.getInstallStep().dependOn(
        &b.addInstallFileWithDir(static_pc_file, .{ .custom = "lib/pkgconfig" }, "librut-static.pc").step,
    );
}
