import sys
sys.path.insert(0, '/home/dmitry/PycharmProjects/PythonDev/Homework_3/src')
from palindrome import palindrome
 
 
def test_phrase():
    assert palindrome("A man, a plan, a canal: Panama") == True

def test_null_string():
    assert palindrome("") == True

def test_false():
    assert palindrome("zo") == False

def test_another():
    assert palindrome("Do geese see God?") == True

def test_numbers():
    assert palindrome("123321") == True