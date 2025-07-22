const std = @import("std");
const assert = std.debug.assert;
const print = std.debug.print;
const testing = std.testing;

const stdin = std.io.getStdIn().reader();

pub const max_candidates = 9;
pub const min_candidates = 2;
pub const max_voter_count = 20;
pub const min_voter_count = 1;
pub const max_input_buffer_size = 100;

pub var pair_count: usize = 0;
pub var candidate_count: usize = 0;
pub var candidates: [max_candidates][]u8 = undefined;
pub var preference_matrix: [max_candidates][max_candidates]u8 = undefined;
pub var locked_matrix: [max_candidates][max_candidates]bool = undefined;

pub const Pair = struct {
    winner_index: usize,
    loser_index: usize,
};

var gpa = std.heap.GeneralPurposeAllocator(.{
    .enable_memory_limit = true,
}){};
const allocator = gpa.allocator();
var pairs = std.ArrayList(Pair).init(allocator);

pub const TidemanError = error{
    InvalidCandidateCount,
    NonAlphabeticCandidate,
    InvalidVoterCount,
    InputCannotBeNull,
};

pub fn main() !void {
    defer pairs.deinit();
    const args: [][*:0]u8 = std.os.argv;
    validateCommandLineArg(args) catch |err| {
        printErrorMessage(err);
        return;
    };

    candidate_count = args.len - 1;
    assert(candidate_count >= min_candidates);
    assert(candidate_count <= max_candidates);
    for (args[1..], 0..) |arg, i| {
        candidates[i] = std.mem.span(arg);
    }

    print("Number of voters (max {}): ", .{max_voter_count});
    var input_buffer: [max_input_buffer_size]u8 = undefined;
    const user_input = stdin.readUntilDelimiterOrEof(&input_buffer, '\n') catch |err| {
        printErrorMessage(err);
        return;
    } orelse {
        printErrorMessage(TidemanError.InputCannotBeNull);
        return;
    };
    const voter_count = std.fmt.parseInt(u8, user_input, 0) catch |err| {
        printErrorMessage(err);
        return;
    };

    if ((voter_count < min_voter_count) or (voter_count > max_voter_count)) {
        printErrorMessage(TidemanError.InvalidVoterCount);
        return;
    }
    assert(voter_count >= min_voter_count);
    assert(voter_count <= max_voter_count);

    for (0..candidate_count) |p| {
        for (0..candidate_count) |q| {
            preference_matrix[p][q] = 0;
        }
    }

    // Collecting votes
    var i: usize = 1;
    while (i <= voter_count) : (i += 1) {
        var ranks: [max_candidates]usize = undefined;
        for (1..(candidate_count + 1)) |rank| {
            while (true) {
                print("Rank {}: ", .{rank});
                var input_buffer_2: [max_input_buffer_size]u8 = undefined;
                const user_input_2 = try stdin.readUntilDelimiterOrEof(&input_buffer_2, '\n') orelse {
                    printErrorMessage(TidemanError.InputCannotBeNull);
                    return;
                };
                validateVoterCandidate(user_input_2) catch |err| {
                    printErrorMessage(err);
                    return;
                };
                if (vote(rank, user_input_2, &ranks)) break;
                print("Candidate does not exixt! Try again.\n", .{});
            }
        }
        recoredPreference(&ranks);
        print("\n", .{});
    }

    addPairs() catch |err| {
        printErrorMessage(err);
        return;
    };
    sortPairs();
    lockPairs();
    printWinner();
}

pub fn lockPairs() void {
    assert(candidate_count >= min_candidates);
    // Max possible pairs
    assert(pair_count <= (candidate_count * (candidate_count - 1)) / 2);

    for (0..candidate_count) |r| {
        for (0..candidate_count) |c| {
            locked_matrix[r][c] = false;
        }
    }

    const CycleDetector = struct {
        fn hasCycle(
            winner: usize,
            loser: usize,
            visited: *[max_candidates]bool,
            path: *[max_candidates]bool,
        ) bool {
            if (path[loser]) return true;
            if (visited[loser]) return false;

            visited[loser] = true;
            path[loser] = true;

            for (0..candidate_count) |next| {
                if (locked_matrix[loser][next] and hasCycle(winner, next, visited, path)) {
                    return true;
                }
            }

            path[loser] = false;
            return false;
        }
    };

    for (0..pair_count) |i| {
        const winner = pairs.items[i].winner_index;
        const loser = pairs.items[i].loser_index;

        var visited: [max_candidates]bool = [_]bool{false} ** max_candidates;
        var path: [max_candidates]bool = [_]bool{false} ** max_candidates;

        locked_matrix[winner][loser] = true;
        if (CycleDetector.hasCycle(winner, loser, &visited, &path)) {
            locked_matrix[winner][loser] = false;
        }
    }
}

pub fn printWinner() void {
    assert(candidate_count >= min_candidates);
    assert(candidate_count <= max_candidates);

    for (0..candidate_count) |candidate| {
        var is_source = true;
        for (0..candidate_count) |other| {
            if (locked_matrix[other][candidate]) {
                is_source = false;
                break;
            }
        }
        if (is_source) {
            print("{s}\n", .{candidates[candidate]});
            return;
        }
    }
}

pub fn sortPairs() void {
    var swapped = false;
    for (0..pair_count) |_| {
        swapped = false;
        for (0..(pair_count - 1)) |j| {
            if (preference_matrix[pairs.items[j].winner_index][pairs.items[j].loser_index] <
                preference_matrix[pairs.items[j + 1].winner_index][pairs.items[j + 1].loser_index])
            {
                std.mem.swap(Pair, &pairs.items[j], &pairs.items[j + 1]);
                swapped = true;
            }
        }
        if (!swapped) break;
    }
}

pub fn addPairs() !void {
    for (0..candidate_count) |r| {
        for ((r + 1)..candidate_count) |c| {
            if (preference_matrix[r][c] > preference_matrix[c][r]) {
                try pairs.append(Pair{
                    .winner_index = r,
                    .loser_index = c,
                });
                pair_count += 1;
            } else if (preference_matrix[r][c] < preference_matrix[c][r]) {
                try pairs.append(Pair{
                    .winner_index = c,
                    .loser_index = r,
                });
                pair_count += 1;
            }
        }
    }
}

pub fn recoredPreference(ranks: *[max_candidates]usize) void {
    assert(ranks.len > 0);
    for (0..candidate_count) |r| {
        for ((r + 1)..candidate_count) |c| {
            if (ranks[r] != ranks[c]) {
                preference_matrix[ranks[r]][ranks[c]] += 1;
            }
        }
    }
}

pub fn vote(rank: usize, name: []u8, ranks: *[max_candidates]usize) bool {
    assert(rank > 0);
    assert(name.len != 0);
    for (candidates[0..candidate_count], 0..) |candidate, i| {
        if (std.mem.eql(u8, name, candidate)) {
            ranks[rank - 1] = i;
            return true;
        }
    }
    return false;
}

pub fn validateVoterCandidate(voters_candidate: []u8) !void {
    assert(voters_candidate.len > 0);
    for (voters_candidate) |c| {
        if (!std.ascii.isAlphabetic(c)) {
            return TidemanError.NonAlphabeticCandidate;
        }
    }
}

pub fn validateCommandLineArg(args: [][*:0]u8) !void {
    assert(args.len > 0);
    if (args.len < 3 or args.len > max_candidates + 1) {
        return TidemanError.InvalidCandidateCount;
    }

    for (args[1..]) |arg| {
        for (std.mem.span(arg)) |c| {
            if (!std.ascii.isAlphabetic(c)) {
                return TidemanError.NonAlphabeticCandidate;
            }
        }
    }
}

pub fn printErrorMessage(err: anyerror) void {
    switch (err) {
        TidemanError.InvalidCandidateCount => {
            print(
                "A minimum of {} and a maximum of {} candidates allowed\n",
                .{ min_candidates, max_candidates },
            );
            print("\n", .{});
            print(
                "Usage: zig run tideman.zig -- Candidate1 Candidate2 [Candidate3..{}]\n",
                .{max_candidates},
            );
        },

        TidemanError.InvalidVoterCount => print(
            "A minimum of {} and a maximum of {} voters allowed\n",
            .{ min_voter_count, max_voter_count },
        ),

        TidemanError.NonAlphabeticCandidate => print(
            "Candidate names must be alphabetic.\n",
            .{},
        ),

        TidemanError.InputCannotBeNull => print(
            "Input cannot be null.\n",
            .{},
        ),

        anyerror.InvalidCharacter => print(
            "Number of voters must be an Integer\n",
            .{},
        ),

        anyerror.StreamTooLong, anyerror.Overflow => print(
            "Input exceeds maximum length of {}.\n",
            .{max_input_buffer_size},
        ),
        else => print("Found error! Aborting...\n", .{}),
    }
}

test "validate candidates minimum" {
    var args = [_][*:0]u8{
        @ptrCast(@constCast("tideman")),
    };
    try testing.expectError(
        TidemanError.InvalidCandidateCount,
        validateCommandLineArg(&args),
    );

    var args_2 = [_][*:0]u8{
        @ptrCast(@constCast("tideman")),
        @ptrCast(@constCast("Alice")),
    };
    try testing.expectError(
        TidemanError.InvalidCandidateCount,
        validateCommandLineArg(&args_2),
    );
}

test "validate candidates maximum" {
    var args = [_][*:0]u8{
        @ptrCast(@constCast("tideman")),
        @ptrCast(@constCast("A")), // 1
        @ptrCast(@constCast("B")), // 2
        @ptrCast(@constCast("C")), // 3
        @ptrCast(@constCast("D")), // 4
        @ptrCast(@constCast("E")), // 5
        @ptrCast(@constCast("F")), // 6
        @ptrCast(@constCast("G")), // 7
        @ptrCast(@constCast("H")), // 8
        @ptrCast(@constCast("I")), // 9
        @ptrCast(@constCast("J")), // 10
    };
    try testing.expectError(
        TidemanError.InvalidCandidateCount,
        validateCommandLineArg(&args),
    );
}

test "validate candidates name to be alphabetic" {
    var args = [_][*:0]u8{
        @ptrCast(@constCast("tideman")),
        @ptrCast(@constCast("Alice")),
        @ptrCast(@constCast("Bob2")),
    };
    try testing.expectError(
        TidemanError.NonAlphabeticCandidate,
        validateCommandLineArg(&args),
    );

    var args_2 = [_][*:0]u8{
        @ptrCast(@constCast("tideman")),
        @ptrCast(@constCast("Alice")),
        @ptrCast(@constCast("Charlie")),
        @ptrCast(@constCast("Charlie!")),
    };
    try testing.expectError(
        TidemanError.NonAlphabeticCandidate,
        validateCommandLineArg(&args_2),
    );

    const args_3: []u8 = @ptrCast(@constCast("Alice1!"));
    try testing.expectError(
        TidemanError.NonAlphabeticCandidate,
        validateVoterCandidate(args_3),
    );
}

test "validate valid candidates" {
    var args = [_][*:0]u8{
        @ptrCast(@constCast("tideman")),
        @ptrCast(@constCast("Alice")),
        @ptrCast(@constCast("Charlie")),
    };
    try validateCommandLineArg(&args);

    var args_2 = [_][*:0]u8{
        @ptrCast(@constCast("tideman")),
        @ptrCast(@constCast("A")), // 1
        @ptrCast(@constCast("B")), // 2
        @ptrCast(@constCast("C")), // 3
        @ptrCast(@constCast("D")), // 4
        @ptrCast(@constCast("E")), // 5
        @ptrCast(@constCast("F")), // 6
        @ptrCast(@constCast("G")), // 7
        @ptrCast(@constCast("H")), // 8
        @ptrCast(@constCast("I")), // 9
    };
    try validateCommandLineArg(&args_2);

    const args_3: []u8 = @ptrCast(@constCast("Alice"));
    try validateVoterCandidate(args_3);
}
