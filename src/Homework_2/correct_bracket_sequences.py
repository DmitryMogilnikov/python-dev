def correct_bracket_sequences(n: int, left_counter: int = 0, right_counter: int = 0, result: str = ''):
    if left_counter + right_counter == 2 * n:
        print(result)
        return
    if left_counter < n:
        correct_bracket_sequences(n, left_counter + 1, right_counter, result + '(')
    if right_counter < left_counter:
        correct_bracket_sequences(n, left_counter, right_counter + 1, result + ')')


correct_bracket_sequences(int(input()))

