"""Width of the List card, or of the orange control Column, in a screenshot.

    python3 scripts/measure.py <screenshot.png> [card|column]

card (default): the List card is white on the grey grouped background, so the card
width is the widest white run that does not span the whole row. A blank screen
has only full-width white rows, so it measures 0.
column: the widest run of the control Column's orange background (#FFD8A8).
Uses only the standard library: the PNG is converted to BMP with `sips` first.
"""
import struct, subprocess, sys, tempfile, os

def rows(path):
    with tempfile.TemporaryDirectory() as tmp:
        bmp = os.path.join(tmp, 'shot.bmp')
        subprocess.run(['sips', '-s', 'format', 'bmp', path, '--out', bmp], check=True, capture_output=True)
        data = open(bmp, 'rb').read()
    offset = struct.unpack_from('<I', data, 10)[0]
    width, height = struct.unpack_from('<ii', data, 18)
    bpp = struct.unpack_from('<H', data, 28)[0] // 8
    stride = (width * bpp + 3) & ~3
    flipped = height > 0
    height = abs(height)
    for y in range(height):
        src = (height - 1 - y) if flipped else y
        base = offset + src * stride
        yield y, [data[base + x * bpp: base + x * bpp + 3] for x in range(width)]
