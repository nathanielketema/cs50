const std = @import("std");
const print = std.debug.print;
const testing = std.testing;
const stdin = std.io.getStdIn().reader();

const MAX_CANDIDATES: comptime_int = 9;
var pair_count: usize = 0;
var candidate_count: usize = 0;
var candidates: [MAX_CANDIDATES][]u8 = undefined;
var preference: [MAX_CANDIDATES][MAX_CANDIDATES]u8 = undefined;

const Pair = struct {
    winner: usize = undefined,
    loser: usize = undefined,
};

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();
var pairs = std.ArrayList(Pair).init(allocator);

pub const MyErrors = error{
    ArgumentNotSatisfied,
    CandidateNotAlphabetic,
};

pub fn main() !void {
    const args: [][*:0]u8 = std.os.argv;
    validateCandidates(args) catch |err| {
        printErrorMessage(err);
        return;
    };
    candidate_count = args.len - 1;
    for (args[1..], 0..) |candidate, i| {
        candidates[i] = std.mem.span(candidate);
    }

    print("Number of voters: ", .{});

    const buffer: []u8 = try allocator.alloc(u8, 5);
    const user_input: ?[]const u8 = stdin.readUntilDelimiterOrEof(buffer, '\n') catch |err| {
        printErrorMessage(err);
        return;
    };
    const voter_count: u8 = std.fmt.parseInt(u8, user_input orelse return, 0) catch |err| {
        printErrorMessage(err);
        return;
    };

    for (0..candidate_count) |p| {
        for (0..candidate_count) |q| {
            preference[p][q] = 0;
        }
    }

    var i: usize = 1;
    while (i <= voter_count) : (i += 1) {
        var ranks: [MAX_CANDIDATES]usize = undefined;
        for (1..(candidate_count + 1)) |rank| {
            while (true) {
                print("Rank {}: ", .{rank});
                var buf: [100]u8 = undefined;
                const input = try stdin.readUntilDelimiterOrEof(&buf, '\n');
                if (vote(rank, input.?, ranks[0..])) break;
                if (vote(rank, input.?, ranks[0..])) break;
                print("Candidate does not exixt!\nTry again\n\n", .{});
            }
        }
        print("\n", .{});

        recoredPreference(ranks[0..]);
    }

    addPairs() catch |err| {
        printErrorMessage(err);
        return;
    };

    sortPairs();
}

fn sortPairs() void {
    var swapped: bool = undefined;
    for (0..(pair_count - 1)) |i| {
        swapped = false;
        for (0..(pair_count - i - 1)) |j| {
            if (preference[pairs.items[j].winner][pairs.items[j].loser] < preference[pairs.items[j + 1].winner][pairs.items[j + 1].loser]) {
                std.mem.swap(Pair, &pairs.items[j], &pairs.items[j]);
                swapped = true;
            }
        }
        if (swapped == false) break;
    }
}

fn addPairs() !void {
    for (0..candidate_count) |r| {
        for ((r + 1)..candidate_count) |c| {
            if (preference[r][c] > preference[c][r]) {
                try pairs.append(Pair{
                    .winner = r,
                    .loser = c,
                });
                pair_count += 1;
            } else if (preference[r][c] < preference[c][r]) {
                try pairs.append(Pair{
                    .winner = c,
                    .loser = r,
                });
                pair_count += 1;
            }
        }
    }
}

fn recoredPreference(ranks: *[MAX_CANDIDATES]usize) void {
    for (0..candidate_count) |r| {
        for ((r + 1)..candidate_count) |c| {
            if (ranks[r] != ranks[c]) {
                preference[ranks[r]][ranks[c]] += 1;
            }
        }
    }
}

fn vote(rank: usize, name: []u8, ranks: *[MAX_CANDIDATES]usize) bool {
    for (candidates[0..candidate_count], 0..) |candidate, i| {
        if (std.mem.eql(u8, name, candidate)) {
            ranks.*[rank - 1] = i;
            return true;
        }
    }
    return false;
}

pub fn validateCandidates(args: [][*:0]u8) !void {
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

//pub fn validatePreference() !void {}

fn printErrorMessage(err: anyerror) void {
    switch (err) {
        MyErrors.ArgumentNotSatisfied => {
            print("A minimum of 2 and a maximum of {} candidates allowed\n", .{MAX_CANDIDATES});
            print("\n", .{});
            print("Usage: zig run tideman.zig -- Candidate1 Candidate2 [Candidate3]..[Candidate9]\n", .{});
        },
        MyErrors.CandidateNotAlphabetic => print("Candidate must be alphabetic!\n", .{}),
        anyerror.InvalidCharacter => print("Input must be an integer!\n", .{}),
        anyerror.StreamTooLong, anyerror.Overflow => print("A maximum of 255 voters allowed\n", .{}),
        else => print("Found error! Aborting...\n", .{}),
    }
}

test "validate candidate - 2 candidates" {
    var program_name = "tideman".*;
    var alice = "Alice".*;
    var bob = "Bob".*;

    var args = [_][*:0]u8{
        @ptrCast(&program_name),
        @ptrCast(&alice),
        @ptrCast(&bob),
    };

    try validateCandidates(&args);
}

test "validate candidate - only 1 candidate" {
    var program_name = "tideman".*;
    var alice = "Alice".*;

    var args = [_][*:0]u8{
        @ptrCast(&program_name),
        @ptrCast(&alice),
    };

    try testing.expectError(MyErrors.ArgumentNotSatisfied, validateCandidates(&args));
}

test "validate candidate - no candidates" {
    var program_name = "tideman".*;

    var args = [_][*:0]u8{
        @ptrCast(&program_name),
    };

    try testing.expectError(MyErrors.ArgumentNotSatisfied, validateCandidates(&args));
}

test "validate candidate - too many candidates (10)" {
    var program_name = "tideman".*;
    var a = "A".*;
    var b = "B".*;
    var c = "C".*;
    var d = "D".*;
    var e = "E".*;
    var f = "F".*;
    var g = "G".*;
    var h = "H".*;
    var i = "I".*;
    var j = "J".*;

    var args = [_][*:0]u8{
        @ptrCast(&program_name),
        @ptrCast(&a),
        @ptrCast(&b),
        @ptrCast(&c),
        @ptrCast(&d),
        @ptrCast(&e),
        @ptrCast(&f),
        @ptrCast(&g),
        @ptrCast(&h),
        @ptrCast(&i),
        @ptrCast(&j),
    };

    try testing.expectError(MyErrors.ArgumentNotSatisfied, validateCandidates(&args));
}

test "validate candidate - numeric characters" {
    var program_name = "tideman".*;
    var alice = "Alice".*;
    var bob2 = "Bob2".*;

    var args = [_][*:0]u8{
        @ptrCast(&program_name),
        @ptrCast(&alice),
        @ptrCast(&bob2),
    };

    try testing.expectError(MyErrors.CandidateNotAlphabetic, validateCandidates(&args));
}

test "validate candidate - special characters" {
    var program_name = "tideman".*;
    var alice = "Alice".*;
    var bob_exclaim = "Bob!".*;

    var args = [_][*:0]u8{
        @ptrCast(&program_name),
        @ptrCast(&alice),
        @ptrCast(&bob_exclaim),
    };

    try testing.expectError(MyErrors.CandidateNotAlphabetic, validateCandidates(&args));
}

test "validate candidate - maximum 9 candidates" {
    var program_name = "tideman".*;
    var alice = "Alice".*;
    var bob = "Bob".*;
    var charlie = "Charlie".*;
    var david = "David".*;
    var eve = "Eve".*;
    var frank = "Frank".*;
    var grace = "Grace".*;
    var henry = "Henry".*;
    var ivy = "Ivy".*;

    var args = [_][*:0]u8{
        @ptrCast(&program_name),
        @ptrCast(&alice),
        @ptrCast(&bob),
        @ptrCast(&charlie),
        @ptrCast(&david),
        @ptrCast(&eve),
        @ptrCast(&frank),
        @ptrCast(&grace),
        @ptrCast(&henry),
        @ptrCast(&ivy),
    };

    try validateCandidates(&args);
}
