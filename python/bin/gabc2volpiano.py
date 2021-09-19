# accepts gabc on the stdin, prints volpiano

import sys
from os.path import dirname, realpath

my_python_root = dirname(dirname(realpath(__file__)))
sys.path.append(my_python_root)

from adiutor.conversion import gabc2volpiano

input = sys.stdin.read()
print(gabc2volpiano(input))
