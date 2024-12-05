//! https://adventofcode.com/2024/day/5

const std = @import("std");
const List = std.ArrayList;
const Map = std.AutoHashMap;

const tokenizeSca = std.mem.tokenizeScalar;
const splitSca = std.mem.splitScalar;
const parseInt = std.fmt.parseInt;
const print = std.debug.print;
const eql = std.mem.eql;
const contains = std.mem.containsAtLeast;
const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day05.txt");

pub fn main() !void {
    var rules = Map(i32, List(i32)).init(gpa);
    var pages = List([]i32).init(gpa);
    defer {
        var rules_it = rules.iterator();
        while (rules_it.next()) |rule| {
            rule.value_ptr.deinit();
        }
        rules.deinit();
        pages.deinit();
    }

    var it = splitSca(u8, data, '\n');
    var in_rules = true;
    while (it.next()) |item| {
        if (eql(u8, item, "")) {
            in_rules = false;
            continue;
        }

        if (in_rules) {
            var pair = tokenizeSca(u8, item, '|');
            const rule = try rules.getOrPut(try parseInt(i32, pair.next().?, 10));

            if (!rule.found_existing) {
                rule.value_ptr.* = List(i32).init(gpa);
                try rule.value_ptr.*.append(try parseInt(i32, pair.next().?, 10));
            } else {
                try rule.value_ptr.*.append(try parseInt(i32, pair.next().?, 10));
            }
        } else {
            var page = List(i32).init(gpa);

            var page_items = tokenizeSca(u8, item, ',');
            while (page_items.next()) |page_item| {
                try page.append(try parseInt(i32, page_item, 10));
            }
            try pages.append(try page.toOwnedSlice());
        }
    }

    var part01: i32 = 0;
    var part02: i32 = 0;
    var was_corrupted: bool = false;
    for (pages.items) |page| {
        var i: usize = page.len - 1;
        while (i > 0) : (i -= 1) {
            var index_rules = rules.get(page[i]) orelse continue;

            var j: usize = 0;
            while (j < page[0..i].len) {
                if (contains(i32, index_rules.items, 1, &[_]i32{page[j]})) {
                    const element = page[j];
                    page[j] = page[i];
                    page[i] = element;
                    was_corrupted = true;

                    if (rules.get(element)) |new_rules| {
                        index_rules = new_rules;
                    }

                    continue;
                }
                j += 1;
            }
        }
        if (was_corrupted) {
            part02 += page[(page.len - 1) / 2];
            was_corrupted = false;
        } else {
            part01 += page[(page.len - 1) / 2];
        }
    }
    print("***Day 05***\nPart 01: {}\nPart 02: {}\n", .{ part01, part02 });
}
