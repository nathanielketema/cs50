const std = @import("std");
const print = std.debug.print;
const testing = std.testing;
const assert = std.debug.assert;
const stdin = std.io.getStdIn().reader();

const max_words = 500;

const Grade = enum {
    before_grade_1,
    grade_1,
    grade_2,
    grade_3,
    grade_4,
    grade_5,
    grade_6,
    grade_7,
    grade_8,
    grade_9,
    grade_10,
    grade_11,
    grade_12,
    grade_13,
    grade_14,
    grade_15,
    grade_16,
    grade_16_plus,

    fn to_string(grade: Grade) []const u8 {
        switch (grade) {
            .before_grade_1 => return "Before Grade 1\n",
            .grade_1 => return "Grade 1\n",
            .grade_2 => return "Grade 2\n",
            .grade_3 => return "Grade 3\n",
            .grade_4 => return "Grade 4\n",
            .grade_5 => return "Grade 5\n",
            .grade_6 => return "Grade 6\n",
            .grade_7 => return "Grade 7\n",
            .grade_8 => return "Grade 8\n",
            .grade_9 => return "Grade 9\n",
            .grade_10 => return "Grade 10\n",
            .grade_11 => return "Grade 11\n",
            .grade_12 => return "Grade 12\n",
            .grade_13 => return "Grade 13\n",
            .grade_14 => return "Grade 14\n",
            .grade_15 => return "Grade 15\n",
            .grade_16 => return "Grade 16\n",
            .grade_16_plus => return "Grade 16+\n",
        }
    }
};

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
        const result = readability_grade(user_input.?);
        print("{s}", .{result.to_string()});
    } else {
        print("\nInput not provided!\n", .{});
        return;
    }
}

fn readability_grade(input: []const u8) Grade {
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

    if (index < 1) {
        return .before_grade_1;
    } else {
        switch (index) {
            1 => return .grade_1,
            2 => return .grade_2,
            3 => return .grade_3,
            4 => return .grade_4,
            5 => return .grade_5,
            6 => return .grade_6,
            7 => return .grade_7,
            8 => return .grade_8,
            9 => return .grade_9,
            10 => return .grade_10,
            11 => return .grade_11,
            12 => return .grade_12,
            13 => return .grade_13,
            14 => return .grade_14,
            15 => return .grade_15,
            16 => return .grade_16,
            else => return .grade_16_plus,
        }
    }
}

test "before grade 1" {
    try testing.expect(
        readability_grade(
            "One fish. Two fish. Red fish. Blue fish.",
        ) == .before_grade_1,
    );
}

test "grade 2" {
    try testing.expect(
        readability_grade(
            "Would you like them here or there? I would not like them here or there. " ++
                "I would not like them anywhere.",
        ) == .grade_2,
    );
}

test "grade 3" {
    try testing.expect(
        readability_grade(
            "Congratulations! Today is your day. You're off to Great Places! " ++
                "You're off and away!",
        ) == .grade_3,
    );
}

test "grade 5" {
    try testing.expect(
        readability_grade(
            "Harry Potter was a highly unusual boy in many ways. For one thing, " ++
                "he hated the summer holidays more than any other time of year. For another, " ++
                "he really wanted to do his homework, but was forced to do it in secret," ++
                "in the dead of the night. And he also happened to be a wizard.",
        ) == .grade_5,
    );
}

test "grade 7" {
    try testing.expect(
        readability_grade(
            "In my younger and more vulnerable years my father gave me some advice that " ++
                "I've been turning over in my mind ever since.",
        ) == .grade_7,
    );
}

test "grade 8" {
    try testing.expect(
        readability_grade(
            "Alice was beginning to get very tired of sitting by her sister on the bank, " ++
                "and of having nothing to do: once or twice she had peeped into the book her " ++
                "sister was reading, but it had no pictures or conversations in it, \"and " ++
                "what is the use of a book,\" thought Alice \"without pictures or conversation?\"",
        ) == .grade_8,
    );

    try testing.expect(
        readability_grade(
            "When he was nearly thirteen, my brother Jem got his arm badly broken " ++
                "at the elbow. When it healed, and Jem's fears of never being able to play " ++
                "football were assuaged, he was seldom self-conscious about his injury. " ++
                "His left arm was somewhat shorter than his right; when he stood or walked, " ++
                "the back of his hand was at right angles to his body, his thumb " ++
                "parallel to his thigh.",
        ) == .grade_8,
    );
}

test "grade 9" {
    try testing.expect(
        readability_grade(
            "There are more things in Heaven and Earth, Horatio, " ++
                "than are dreamt of in your philosophy.",
        ) == .grade_9,
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
        ) == .grade_10,
    );
}

test "grade 16 plus" {
    try testing.expect(
        readability_grade(
            "A large class of computational problems involve the determination of " ++
                "properties of graphs, digraphs, integers, arrays of integers, " ++
                "finite families of finite sets, boolean formulas and elements of " ++
                "other countable domains.",
        ) == .grade_16_plus,
    );
}
