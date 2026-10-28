# expo-ui Column zero width repro

Reproduction and fix check for [expo/expo#52410](https://github.com/expo/expo/issues/52410):
on iOS, a universal `Column` from `@expo/ui` with no size of its own lays out at width 0
since `@expo/ui` 58.0.23, so a `List` inside it renders nothing.
