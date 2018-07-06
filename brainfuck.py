"""Simple Brainfuck Interpreter."""

import os


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
    output = ""
    qnt = 1
    flag = False
    stack = []

    for char in code:
        if char == "[":
            stack.append("[")
            flag = True
            qnt = cells[-1] if flag else 1
        if char == "]" and stack:
            stack.pop()
        if not stack:
            flag = False
            qnt = 1
        if char == ">":
            pointer += 1
            if len(cells) - 1 < pointer:
                cells.append(0)
        elif char == "<":
            pointer -= 1 if pointer > 0 else 0
        elif char == "+":
            cells[pointer] += qnt
        elif char == "-":
            cells[pointer] -= qnt if cells[pointer] >= 0 else 0
        elif char == ".":
            output += chr(cells[pointer])

#    for char in code:
#        if char == ">":
#            pointer += 1
#            cells[pointer] = 0 if len(cells) < pointer else cells[pointer]
#        elif char == "<":
#            pointer -= 1 if pointer > 0 else 0
#        elif char == "+":
#            cells[pointer] += 1
#        elif char == "-":
#            cells[pointer] -= 1 if cells[pointer] >= 0 else 0
#        elif char == ".":
#            output += chr(cells[pointer])

    return output


if __name__ == '__main__':
    print(filter_file("hello_world.bf"))
    print(execute_code("++++++++[>++[>+++++>+++++++<<-]<-]>>++++++.>-------.++.+++++++++.-----.+++."))
    print(execute_code("++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+<<<<<<<-]>>.>---.+++++++..+++.>>.<-.+++.------.--------.>>+.>++."))
