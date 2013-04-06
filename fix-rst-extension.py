"""

    Walk tree and add .rst extension to files missing it

"""

import os
import sys

top = sys.argv[1]

for root, dirs, files in os.walk(top, topdown=False):
    for name in files:
        if not "." in name:
            os.rename(os.path.join(root, name), os.path.join(root, name + ".rst"))
