const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const testing = std.testing;

const util = @import("util.zig");
const gpa = util.gpa;

const splitSca = std.mem.splitScalar;
const parseInt = std.fmt.parseInt;
const print = std.debug.print;

const file = @embedFile("data/day02.txt");

pub fn main() !void {
    var bad_reports = List([]i32).init(gpa);
    defer bad_reports.deinit();

    // PART 1
    const safe_reports = try checkReports(file, &bad_reports);
    const safe_reports_clean = safe_reports + cleanReports(bad_reports);

    print("***Day 02***\nPart 01: {}\nPart 02: {}\n", .{ safe_reports, safe_reports_clean });
}

fn checkReports(data: []const u8, bad_reports: *List([]i32)) !i32 {
    var reports = splitSca(u8, data, '\n');

    var safe_reports: i32 = 0;
    reports_loop: while (reports.next()) |report| {
        var parsed_report = splitSca(u8, report, ' ');

        var numeric_report = List(i32).init(gpa);
        defer numeric_report.deinit();

        while (parsed_report.next()) |level| {
            numeric_report.append(
                parseInt(i32, level, 10) catch continue :reports_loop,
            ) catch continue :reports_loop;
        }

        if (!isReportSafe(numeric_report.items)) {
            try bad_reports.append(try gpa.dupe(i32, numeric_report.items));
            continue :reports_loop;
        }

        safe_reports += 1;
    }
    return safe_reports;
}

fn cleanReports(bad_reports: List([]i32)) i32 {
    var result: i32 = 0;

    var i: usize = 0;
    while (i < bad_reports.items.len) : (i += 1) {
        var bad_report = bad_reports.items[i];

        var j: usize = 0;
        inner: while (j < bad_report.len) : (j += 1) {
            const modified_report = std.mem.concat(
                gpa,
                i32,
                &[_][]const i32{ bad_report[0..j], bad_report[j + 1 ..] },
            ) catch bad_report;
            defer gpa.free(modified_report);

            if (isReportSafe(modified_report)) {
                result += 1;
                break :inner;
            }
        }
    }

    return result;
}

fn isReportSafe(list: []i32) bool {
    const is_decreasing = list[0] > list[list.len - 1];
    var i: usize = 0;
    while (i < list.len - 1) : (i += 1) {
        if (is_decreasing) {
            if (list[i] <= list[i + 1]) {
                return false;
            }
            if (list[i] - list[i + 1] < 1 or
                list[i] - list[i + 1] > 3)
            {
                return false;
            }
        } else {
            if (list[i] >= list[i + 1]) {
                return false;
            }
            if (list[i + 1] - list[i] < 1 or
                list[i + 1] - list[i] > 3)
            {
                return false;
            }
        }
    }
    return true;
}
