const std = @import("std");
const print = std.debug.print;
const testing = std.testing;

var pair_count: usize = 0;
var candidate_count: usize = 0;

const pair = struct {
    winner: []const u8 = undefined,
    loser: []const u8 = undefined,
};

pub const MyErrors = error{ ArgumentNotSatisfied, CandidateNotAlphabetic };

pub fn main() !void {
    const args: [][*:0]u8 = std.os.argv;
    validateCandidates(args) catch |err| {
        printErrorMessage(err);
        return;
    };

    candidate_count = args.len - 1;
    var candidates: [9][]u8 = undefined;
    for (args[1..], 0..) |candidate, i| {
        candidates[i] = std.mem.span(candidate);
    }
}

pub fn validateCandidates(args: [][*:0]u8) MyErrors!void {
    if (args.len < 3 or args.len > 10) {
        return MyErrors.ArgumentNotSatisfied;
    }

    for (args[1..]) |candidate| {
        for (std.mem.span(candidate)) |c| {
            if (!std.ascii.isAlphabetic(c)) {
                return MyErrors.CandidateNotAlphabetic;
            }
        }
    }
}

fn printErrorMessage(err: MyErrors) void {
    switch (err) {
        MyErrors.ArgumentNotSatisfied => {
            print("A minimum of 2 and a maximum of 9 candidates allowed\n", .{});
            print("\n", .{});
            print("Usage: zig run tideman.zig -- Candidate1 Candidate2 [Candidate3]..[Candidate9]\n", .{});
        },
        MyErrors.CandidateNotAlphabetic => print("Candidate must be alphabetic!\n", .{}),
        else => unreachable,
    }
}
