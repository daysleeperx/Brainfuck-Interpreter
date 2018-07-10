"""Simple Brainfuck Interpreter."""


import os
import sys


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
    data_pointer = 0
    cells = [0]
    stack = []
    index = 0
    inp = ""

    while index < len(code):
        char = code[index]
        # increment the data pointer and add cell if needed
        if char == ">":
            data_pointer += 1
            if data_pointer >= len(cells):
                cells.append(0)
        # decrement the data pointer
        elif char == "<":
            data_pointer -= 1 if data_pointer - 1 >= 0 else 0
        # increment the byte at the data pointer
        elif char == "+":
            cells[data_pointer] += 1
        # decrement the byte at the data pointer
        elif char == "-":
            cells[data_pointer] -= 1 if cells[data_pointer] - 1 >= 0 else 0
        # output the byte at the data pointer
        elif char == ".":
            print(chr(cells[data_pointer]), end="")
        # accept one byte of input, storing its value in the byte at the data pointer
        elif char == ",":
            if inp:
                try:
                    cells[data_pointer] = ord(next(inp))
                except StopIteration:
                    inp = ""
            else:
                inp = (x for x in input("Enter: "))
                cells[data_pointer] = ord(next(inp))
        # if the byte at the data pointer is zero, then instead of move the data pointer forward,
        # jump it forward to the command after the matching "]" command
        elif char == "[":
            if cells[data_pointer] == 0:
                stack.append("[")
                while index < len(code):
                    index += 1
                    char = code[index]
                    if char == "]":
                        stack.pop()
                        if not stack: break
                    elif char == "[":
                        stack.append("[")
        # if the byte at the data pointer is nonzero, then instead of moving forward
        # jump it back to the command after the matching "[" command
        elif code[index] == "]":
            if cells[data_pointer] != 0:
                stack.append("]")
                while index >= 0:
                    index -= 1
                    char = code[index]
                    if char == "[":
                        stack.pop()
                        if not stack: break
                    elif char == "]":
                        stack.append("]")
        index += 1


if __name__ == '__main__':
    execute_code(filter_file(sys.argv[1]))

