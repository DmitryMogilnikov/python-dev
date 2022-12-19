import os, sys

sys.path.insert(1, os.path.join(sys.path[0], "../src/Homework_2"))
from largest_number import Solution


def test_largest_number():
    sol = Solution()
    assert sol.largest_number(3, ["1", "783", "2"]) == "78321" 
    assert sol.largest_number(5, ["2", "4", "5", "2", "10"]) == "542210" 
    assert sol.largest_number(3, ["32", "31", "3"]) == "33231" 
    assert sol.largest_number(0, ["32", "31", "3"]) == "" 
    assert sol.largest_number(1, ["32"]) == "32" 
    assert sol.largest_number(3, ["504", "751", "7"]) =="7751504" 

