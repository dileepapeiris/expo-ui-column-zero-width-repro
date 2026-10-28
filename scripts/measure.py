"""Width of the List card, or of the orange control Column, in a screenshot.

    python3 scripts/measure.py <screenshot.png> [card|column]

card (default): the List card is white on the grey grouped background, so the card
width is the widest white run that does not span the whole row. A blank screen
has only full-width white rows, so it measures 0.
column: the widest run of the control Column's orange background (#FFD8A8).
Uses only the standard library: the PNG is converted to BMP with `sips` first.
"""
import struct, subprocess, sys, tempfile, os
