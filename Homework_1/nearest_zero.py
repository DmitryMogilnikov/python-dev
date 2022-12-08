from typing import List


def nearest_zero(len_array: int, array: List[str]) -> List[int]:
    result = [len_array] * len_array
    for i in range(len_array):
        if array[i] == '0':
            result[i] = 0
        else:
            result[i] = result[i - 1] + 1
    return result


houses = input().split()
count_houses = len(houses)

print(list(reversed(houses)))

left_to_right = nearest_zero(count_houses, houses)
right_to_left = list(reversed(nearest_zero(count_houses, list(reversed(houses)))))

answer = list(map(min, (zip(left_to_right, right_to_left))))
print(' '.join(map(str, answer)))
