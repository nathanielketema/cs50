import sys
import unittest


def main():
    print("hello world")


class Test(unittest.TestCase):
    def test(self):
        pass


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "test":
        _ = unittest.main(argv=sys.argv[:1])
    else:
        main()
