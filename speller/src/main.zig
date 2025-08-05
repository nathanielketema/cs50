const std = @import("std");
const print = std.debug.print;
const testing = std.testing;
const assert = std.debug.assert;

pub fn main() !void {
    print("hello world\n", .{});
}
