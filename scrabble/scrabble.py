import sys
import unittest

scoring: dict[str, int] = {
    "A": 1,
    "B": 3,
    "C": 3,
    "D": 2,
    "E": 1,
    "F": 4,
    "G": 2,
    "H": 4,
    "I": 1,
    "J": 8,
    "K": 5,
    "L": 1,
    "M": 3,
    "N": 1,
    "O": 1,
    "P": 3,
    "Q": 1,
    "R": 1,
    "S": 1,
    "T": 1,
    "U": 1,
    "V": 4,
    "W": 4,
    "X": 8,
    "Y": 4,
    "Z": 1,
}


def getScore(word: str) -> int:
    sum = 0
    for c in word:
        sum += scoring.get(c.upper(), 0)
    return sum


def main():
    player1 = input("Player 1: ")
    player2 = input("Player 2: ")
    score_of_player1 = getScore(player1)
    score_of_player2 = getScore(player2)

    if score_of_player1 > score_of_player2:
        print("Player 1 wins!")
    elif score_of_player2 > score_of_player1:
        print("Player 2 wins!")
    else:
        print("Tie!")


class TestScrabbleScore(unittest.TestCase):
    def test_single_letters(self):
        for letter, value in scoring.items():
            with self.subTest(letter=letter):
                self.assertEqual(value, getScore(letter))
                self.assertEqual(value, getScore(letter.lower()))

    def test_empty_string(self):
        self.assertEqual(0, getScore(""))

    def test_word_scores(self):
        test_cases = [
            ("python", 14),  # P(3) + Y(4) + T(1) + H(4) + O(1) + N(1)
            ("quiz", 4),  # Q(1) + U(1) + I(1) + Z(1)
            ("jazz", 11),  # J(8) + A(1) + Z(1) + Z(1)
            ("hello", 8),  # H(4) + E(1) + L(1) + L(1) + O(1)
            ("", 0),
            ("123", 0),
            ("!@#", 0),
            ("héll0", 6),  # H(4) + E(1) + L(1)
        ]
        for word, expected in test_cases:
            with self.subTest(word=word):
                self.assertEqual(expected, getScore(word))

    def test_mixed_case(self):
        self.assertEqual(getScore("Python"), getScore("python"))
        self.assertEqual(getScore("HeLLo"), getScore("hello"))

    def test_non_alphabetic(self):
        self.assertEqual(0, getScore("123"))
        self.assertEqual(0, getScore("!@#"))
        self.assertEqual(6, getScore("h3ll0!"))  # H(4) + L(1) + L(1)

    def test_invalid_characters(self):
        self.assertEqual(0, getScore("å"))
        self.assertEqual(0, getScore("ß"))
        self.assertEqual(0, getScore("你"))  # Non-Latin character

    def test_long_word(self):
        long_word = "supercalifragilisticexpialidocious"
        expected = (
            1  # S
            + 1  # U
            + 3  # P
            + 1  # E
            + 1  # R
            + 3  # C
            + 1  # A
            + 1  # L
            + 1  # I
            + 4  # F
            + 1  # R
            + 1  # A
            + 2  # G
            + 1  # I
            + 1  # L
            + 1  # I
            + 1  # S
            + 1  # T
            + 1  # I
            + 3  # C
            + 1  # E
            + 8  # X
            + 3  # P
            + 1  # I
            + 1  # A
            + 1  # L
            + 1  # I
            + 2  # D
            + 1  # O
            + 3  # C
            + 1  # I
            + 1  # O
            + 1  # U
            + 1
        )  # S
        self.assertEqual(expected, getScore(long_word))


if __name__ == "__main__":
    # Run the game if executed directly
    # Run tests if executed with unittest
    if len(sys.argv) > 1 and sys.argv[1] == "test":
        _ = unittest.main(argv=sys.argv[:1])
    else:
        main()
