class Solution:
    @staticmethod
    def cmp(a: str, b: str) -> bool:
        return a + b < b + a

    def largest_number(self, length: int, nums: list[str]) -> str:
        if length == 0:
            return ""
        for i in range(length):
            for j in range(length - 1 - i):
                if self.cmp(nums[j], nums[j + 1]):
                    nums[j], nums[j + 1] = nums[j + 1], nums[j]

        return "".join(nums)


def main():
    count_numbers = int(input())
    numbers = input().split()
    
    sol = Solution()
    print(sol.largest_number(count_numbers, numbers))

if __name__ == "__main__":
	main()
