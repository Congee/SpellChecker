import unittest
from spellcheck import SpellChecker


class SpellCheckerTestCase(unittest.TestCase):
    def setUp(self):
        self.checker = SpellChecker()

    def test_complete(self):
        self.assertEqual(self.checker.complete(''),
                         ['I', 'The', "I'm", 'You', 'My', 'It', 'But', 'If', 'This', "It's", 'And', 'So', 'He', 'A', 'Just', 'In', 'We', 'What', 'Why', 'No'])

    def test_correct(self):
        self.assertEqual(self.checker.correct('wrrong'), 'wrong')

    def test_guess(self):
        self.assertEqual(self.checker.guess('aa'), ['as', 'era'])


def suite():
    suite = unittest.TestSuite()
    suite.addTest(SpellCheckerTestCase())
    return suite


if __name__ == "__main__":
    unittest.main()
