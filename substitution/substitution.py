import sys
import string


class MissingArgument(Exception):
    pass


class LengthNot26(Exception):
    pass


class NotAlphabetic(Exception):
    pass


class NotUnique(Exception):
    pass


def encipher(plaintext: str, key: str) -> str:
    return "".join(
        (
            key[string.ascii_lowercase.index(c)].lower()
            if c.islower()
            else key[string.ascii_uppercase.index(c)].upper()
            if c.isupper()
            else c
        )
        for c in plaintext
    )


def main():
    try:
        if len(sys.argv) != 2:
            raise MissingArgument("Usage: python3 substitution.py key")

        user_input: str = sys.argv[1]
        if len(user_input) != 26:
            raise LengthNot26("Key must contain 26 characters.")

        if not user_input.isalpha():
            raise NotAlphabetic("Key must only contain alphabetic characters.")

        if len(user_input) != len(set(user_input)):
            raise NotUnique("Key must not contain repeated characters.")

        key: str = user_input
        plaintext = input("plaintext: ")
        cipher: str = encipher(plaintext, key)
        print(f"ciphertext: {cipher}")
    except (MissingArgument, LengthNot26, NotAlphabetic, NotUnique) as e:
        print(e)


if __name__ == "__main__":
    main()
