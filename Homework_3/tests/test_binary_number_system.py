import sys
sys.path.insert(0, '/home/dmitry/PycharmProjects/PythonDev/Homework_3/src')
from binary_number_system import decimal_to_binary

def twos_complement(n, bits=8):
    mask = (1 << bits) - 1
    if n < 0:
        n = ((abs(n) ^ mask) + 1)
    return format(n & mask, 'b')

 
def test_positive_number_5():
    assert decimal_to_binary(5) == format(5, 'b')

def test_positive_number_14():
    assert decimal_to_binary(14) == format(14, 'b')

def test_zero():
    assert decimal_to_binary(0) == format(0, 'b')

def test_negative_number():
    assert decimal_to_binary(-123) == twos_complement(-123 , 8)

def test_negative_number_2():
    assert decimal_to_binary(-79) == twos_complement(-79 , 8)