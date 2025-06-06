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


if __name__ == "__main__":
    main()
