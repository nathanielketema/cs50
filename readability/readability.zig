const std = @import("std");
const print = std.debug.print;
const testing = std.testing;
const assert = std.debug.assert;
const stdin = std.io.getStdIn().reader();

const max_words = 500;

pub fn main() !void {
    print("Text: ", .{});
    var buffer: [max_words]u8 = undefined;
    const user_input = stdin.readUntilDelimiterOrEof(&buffer, '\n') catch |err| {
        switch (err) {
            error.StreamTooLong => {
                print("Input too long! (max: 100 words)\n", .{});
                // Flush the rest of the input
                _ = try stdin.skipUntilDelimiterOrEof('\n');
                return;
            },
            else => {
                print("Error! Program quiting...\n", .{});
                return;
            },
        }
    };

    // Unwrap optional
    if (user_input) |input| {
        assert(input.len != 0);
        const result = readability_grade(input);
        if (result < 1) {
            print("Before Grade 1\n", .{});
        } else if (result > 16) {
            print("Grade 16+\n", .{});
        } else {
            print("Grade {d}\n", .{result});
        }
    } else {
        print("\nInput not provided!\n", .{});
        return;
    }
}

fn readability_grade(input: []const u8) i32 {
    var letters: u16 = 0;
    var words: u16 = 0;
    var sentences: u16 = 0;

    for (input) |c| {
        if (std.ascii.isAlphabetic(c)) {
            letters += 1;
        } 
        if (std.ascii.isWhitespace(c)) {
            words += 1;
        } 
        if (c == '?' or c == '!' or c == '.') {
            sentences += 1;
        }
    }

    // To adjust for the last word, since there is no space after it
    words += 1;

    // Coleman-Liau index: index = 0.0588 * L - 0.296 * S - 15.8
    // where L is the average number of letter in 100 words, (letters / words) * 100
    //       S is the average number of sentences in 100 words, (sentences / words) * 100
    assert(words != 0);
    const L = 100 * (@as(f16, @floatFromInt(letters)) / @as(f16, @floatFromInt(words)));
    const S = 100 * (@as(f16, @floatFromInt(sentences)) / @as(f16, @floatFromInt(words)));

    assert(L != 0);
    assert(S != 0);
    const index: i32 = @intFromFloat(@round(0.0588 * L - 0.296 * S - 15.8));

    return index;
}

test "before grade 1" {
    try testing.expect(
        readability_grade(
            "One fish. Two fish. Red fish. Blue fish.",
        ) < 1,
    );
}

test "grade 2" {
    try testing.expect(
        readability_grade(
            "Would you like them here or there? I would not like them here or there. " ++
                "I would not like them anywhere.",
        ) == 2,
    );
}

test "grade 3" {
    try testing.expect(
        readability_grade(
            "Congratulations! Today is your day. You're off to Great Places! " ++
                "You're off and away!",
        ) == 3,
    );
}

test "grade 5" {
    try testing.expect(
        readability_grade(
            "Harry Potter was a highly unusual boy in many ways. For one thing, " ++
                "he hated the summer holidays more than any other time of year. For another, " ++
                "he really wanted to do his homework, but was forced to do it in secret," ++
                "in the dead of the night. And he also happened to be a wizard.",
        ) == 5,
    );
}

test "grade 7" {
    try testing.expect(
        readability_grade(
            "In my younger and more vulnerable years my father gave me some advice that " ++
                "I've been turning over in my mind ever since.",
        ) == 7,
    );
}

test "grade 8" {
    try testing.expect(
        readability_grade(
            "Alice was beginning to get very tired of sitting by her sister on the bank, " ++
                "and of having nothing to do: once or twice she had peeped into the book her " ++
                "sister was reading, but it had no pictures or conversations in it, \"and " ++
                "what is the use of a book,\" thought Alice \"without pictures or conversation?\"",
        ) == 8,
    );

    try testing.expect(
        readability_grade(
            "When he was nearly thirteen, my brother Jem got his arm badly broken " ++
                "at the elbow. When it healed, and Jem's fears of never being able to play " ++
                "football were assuaged, he was seldom self-conscious about his injury. " ++
                "His left arm was somewhat shorter than his right; when he stood or walked, " ++
                "the back of his hand was at right angles to his body, his thumb " ++
                "parallel to his thigh.",
        ) == 8,
    );
}

test "grade 9" {
    try testing.expect(
        readability_grade(
            "There are more things in Heaven and Earth, Horatio, " ++
                "than are dreamt of in your philosophy.",
        ) == 9,
    );
}

test "grade 10" {
    try testing.expect(
        readability_grade(
            "It was a bright cold day in April, and the clocks were striking thirteen. " ++
                "Winston Smith, his chin nuzzled into his breast in an effort to escape " ++
                "the vile wind, slipped quickly through the glass doors of Victory Mansions, " ++
                "though not quickly enough to prevent a swirl of gritty dust from entering " ++
                "along with him.",
        ) == 10,
    );
}

test "grade 16 plus" {
    try testing.expect(
        readability_grade(
            "A large class of computational problems involve the determination of " ++
                "properties of graphs, digraphs, integers, arrays of integers, " ++
                "finite families of finite sets, boolean formulas and elements of " ++
                "other countable domains.",
        ) > 16,
    );
}
