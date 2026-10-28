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

def widest_run(row, match):
    best = run = 0
    for b, g, r in row:
        if match(r, g, b):
            run += 1
            best = max(best, run)
        else:
            run = 0
    return best

if __name__ == '__main__':
    path = sys.argv[1]
    mode = sys.argv[2] if len(sys.argv) > 2 else 'card'
    if mode == 'card':
        match = lambda r, g, b: r > 245 and g > 245 and b > 245
    else:
        match = lambda r, g, b: abs(r - 255) < 8 and abs(g - 216) < 8 and abs(b - 168) < 8
    width = None
    best = (0, 0)
    all_rows = list(rows(path))
    height = len(all_rows)
    for y, row in all_rows:
        width = len(row)
        # Skip the status bar and the picker (top 22 %) and the home indicator (bottom 5 %).
        if y < 0.22 * height or y > 0.95 * height:
            continue
        w = widest_run(row, match)
        if mode == 'card' and w >= width:
            continue  # a fully white row is background, not a card
        if w > best[0]:
            best = (w, y)
    print(f'{os.path.basename(path)}: {mode} width {best[0]:,} px of {width:,} px (row {best[1]})')
