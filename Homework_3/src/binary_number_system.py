def decimal_to_binary(number: int) -> str:
    if number == 0:
        return '0'
    
    bin_number = ""

    if number > 0:
        while number > 0:
            bin_number = str(number % 2) + bin_number
            number = number // 2

        return bin_number
    
    else:
        bin_number = abs(number)
        bin_number = decimal_to_binary(bin_number)
        bin_number = '0' * (8 - len(bin_number)) + bin_number
        bin_number = list(bin_number)
        
        for i in range(len(bin_number)):
            if bin_number[i] == '1':
                bin_number[i] = '0'
            else:
                bin_number[i] = '1'
        
        for i in range(1, len(bin_number) + 1):
            if bin_number[-i] == '1':
                bin_number[-i] = '0'
            else:
                bin_number[-i] = '1'
                break
        
        return ''.join(bin_number)


if __name__ == "__main__":
    dec_number = int(input())
    result = decimal_to_binary(dec_number)
    print(result)
