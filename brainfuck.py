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

    # TODO: function interpreting the commands


if __name__ == '__main__':
    print(filter_file("hello_world.bf"))
