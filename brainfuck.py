"""Simple Brainfuck Interpreter."""

import os
from functools import reduce


def filter_file(file):
    """
    Function that opens the brainfuck file and parses the input
    removing all the comments and symbols, that are not in the 8 commands
    list.

    :param file: the file to read from
    :exception: Exception
    :return: string
    """
    commands = [">", "<", "+", "-", "[", "]", ".", ","]
    output = ""

    if os.path.isfile(file):
        with open(file, "r") as file:
            for line in file:
                output += "".join(x for x in line if x in commands)
    else:
        raise Exception("File not found!")

    return output


def execute_code(code):
    """
    Execute(print) the cleaned up Brainfuck code.

    :param code: string of Brainfuck code
    :return:
    """
    pointer = 0
    cells = [0]
    stack = []
    output = ""

    for char in code:
        if char == "[":
            stack.append(cells[pointer]) if not stack else stack.append(cells[pointer] // reduce((lambda x, y: x * y), stack))
            continue
        if char == "]":
            stack.pop()
            continue
        if char == ">":
            pointer += 1
            if len(cells) - 1 < pointer:
                cells.append(0)
            continue
        if char == "<":
            pointer -= 1 if pointer >= 0 else 0
            continue
        if char == "+":
            cells[pointer] += reduce((lambda x, y: x * y), stack) if stack else 1
            continue
        if char == "-":
            cells[pointer] -= reduce((lambda x, y: x * y), stack) if stack else 1
            if cells[pointer] < 0:
                cells[pointer] = 0
            continue
        if char == ".":
            output += chr(cells[pointer])

    return output


if __name__ == '__main__':
    #print(filter_file("hello_world.bf"))
    #print(execute_code("++++++++[>++[>+++++>+++++++<<-]<-]>>++++++.>-------.++.+++++++++.-----.+++."))
    #print(execute_code("++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+<<<<<<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++."))
    print(execute_code(filter_file("factorial.bf")))
