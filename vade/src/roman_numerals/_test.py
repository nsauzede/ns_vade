def roman_to_value(string: str):
    roman_digit = {"I": 1, "V": 5, "X": 10, "L": 50, "C": 100, "D": 500, "M": 1000}
    v = 0
    last_n = 0
    count = 1
    for c in string:
        n = roman_digit[c]
        if n == last_n:
            count += 1
            v += n
        else:
            if last_n < n:
                v += n - last_n - last_n
            else:
                v += n
            count = 1
        if count >= 4:
            raise Exception(f"Invalid suite of {count} occurences of {n}")
        last_n = n
    return v


from vadetest import *


class T(unittest.TestCase):
    def test_emptyReturnsZero(self):
        self.assertEqual(0, roman_to_value(""))

    def test_invalidCharThrows(self):
        with self.assertRaises(Exception):
            roman_to_value("Z")

    def test_iReturnsOne(self):
        self.assertEqual(1, roman_to_value("I"))

    def test_iiReturnsTwo(self):
        self.assertEqual(2, roman_to_value("II"))

    def test_iiiReturnsThree(self):
        self.assertEqual(3, roman_to_value("III"))

    def test_iiiiThrows(self):
        with self.assertRaises(Exception):
            roman_to_value("IIII")

    def test_xxxxThrows(self):
        with self.assertRaises(Exception):
            roman_to_value("XXXX")

    def test_vReturnsFive(self):
        self.assertEqual(5, roman_to_value("V"))

    def test_xReturnsTen(self):
        self.assertEqual(10, roman_to_value("X"))

    def test_lReturnsFifty(self):
        self.assertEqual(50, roman_to_value("L"))

    def test_cReturnsHundred(self):
        self.assertEqual(100, roman_to_value("C"))

    def test_dReturnsFiveHundred(self):
        self.assertEqual(500, roman_to_value("D"))

    def test_mReturnsThousand(self):
        self.assertEqual(1000, roman_to_value("M"))

    def test_ivReturnsFour(self):
        self.assertEqual(4, roman_to_value("IV"))

    def test_viReturnsSix(self):
        self.assertEqual(6, roman_to_value("VI"))

    def test_xlReturnsSix(self):
        self.assertEqual(40, roman_to_value("XL"))

    def test_mcmlxxxivReturns1984(self):
        self.assertEqual(1984, roman_to_value("MCMLXXXIV"))

    def test_dclxviReturns666(self):
        self.assertEqual(666, roman_to_value("DCLXVI"))
