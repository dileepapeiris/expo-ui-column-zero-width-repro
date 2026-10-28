# expo-ui Column zero width repro

Reproduction and fix check for [expo/expo#52410](https://github.com/expo/expo/issues/52410):
on iOS, a universal `Column` from `@expo/ui` with no size of its own lays out at width 0
since `@expo/ui` 58.0.23, so a `List` inside it renders nothing.

## Before and after

Left: stock `@expo/ui` 58.0.24. Right: the same project with the fix from the PR,
`ExpoUI` built from source. iPhone 17 simulator, iOS 26.5, captured on 10/28/26.

![List in an unsized Column, before and after](media/list-before-after.png)

The control case keeps a flexible `Spacer` from stretching an unsized `Column`,
which is the behaviour the old code protected. It is unchanged by the fix:

![Spacer in an unsized Column, before and after](media/spacer-before-after.png)

Recording of a cold start of each build, side by side. The screen switches between the two
cases every 5 s:

![Side-by-side recording](media/before-after.gif)

The same recording as an MP4: [media/before-after.mp4](media/before-after.mp4).
Single captures: [before.mp4](media/before.mp4), [after.mp4](media/after.mp4),
[before-list.png](media/before-list.png), [after-list.png](media/after-list.png),
[before-spacer.png](media/before-spacer.png), [after-spacer.png](media/after-spacer.png).

## Measurements

`scripts/measure.py` reads a screenshot with only the Python standard library and reports
the widest run of the List card's white (`card`) or the control Column's orange (`column`).
Screenshots are 1,206 px wide.

| Case | Before | After |
|---|---|---|
| List card width | 0 px (nothing drawn) | 1,110 px |
| Control Column width (Spacer inside) | 494 px | 494 px |

```sh
python3 scripts/measure.py media/before-list.png          # card width 0 px of 1,206 px
python3 scripts/measure.py media/after-list.png           # card width 1,110 px of 1,206 px
python3 scripts/measure.py media/before-spacer.png column # column width 494 px of 1,206 px
python3 scripts/measure.py media/after-spacer.png column  # column width 494 px of 1,206 px
```

## The screen

`App.tsx` shows one `Host` with `flex: 1`. The `list` case is the issue's tree:

```tsx
<Column>
  <List>
    <ListItem>Row 1</ListItem>
    <ListItem>Row 2</ListItem>
    <ListItem>Row 3</ListItem>
  </List>
</Column>
```

The `spacer` case is a `Column` with no width holding a `Text`, a flexible `Spacer` and a
`Text`, with an orange background so its width is visible. The cases cycle every 5 s and
can also be picked with the buttons at the top.

## Run it

```sh
npm install
npx expo start                      # in one terminal
npx expo run:ios                    # in another; builds a development build on a simulator
```

Before: the `list` case is blank. The `spacer` case shows a text-wide orange column.
