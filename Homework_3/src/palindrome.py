import re

def palindrome(phrase: str) -> bool:
    pattern = re.compile('[\W_]+')
    phrase = pattern.sub('', phrase).lower()
    reversed_phrase = phrase[::-1]
    
    return phrase == reversed_phrase

if __name__ == "__main__":
    string = input()
    result = palindrome(string)
    print(result)