from typing import List


def sleight_of_hand(k: int, field: List[str]) -> int:
    result = 0

    for i in field:
        if i in count_numbers.keys():
            count_numbers[i] += 1

    for _, value in count_numbers.items():
        if 0 < value and value <= k:
            result += 1

    return result


num = int(input()) * 2
strings = []
for i in range(4):
    numbers = input()
    strings += numbers

count_numbers = {str(key): 0 for key in range(10)}

answer = sleight_of_hand(k, strings)
print(answer)
