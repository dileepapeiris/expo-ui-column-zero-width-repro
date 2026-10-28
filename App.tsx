import { Column, Host, List, ListItem, Spacer, Text } from '@expo/ui';
import { useEffect, useState } from 'react';
import { Pressable, StyleSheet, Text as RNText, View } from 'react-native';

type Case = 'list' | 'spacer';

const CASES: Case[] = ['list', 'spacer'];
const LABELS: Record<Case, string> = {
  list: 'List in an unsized Column (expo/expo#52410)',
  spacer: 'Control: Spacer in an unsized Column',
};
// The screen cycles through the cases, so a recording covers both without taps.
const CYCLE_MS = 5000;

export default function App() {
  const [current, setCurrent] = useState<Case>('list');

  useEffect(() => {
    const id = setInterval(() => {
      setCurrent((c) => CASES[(CASES.indexOf(c) + 1) % CASES.length]);
    }, CYCLE_MS);
    return () => clearInterval(id);
  }, []);

  return (
    <View style={styles.screen}>
      <View style={styles.picker}>
        {CASES.map((c) => (
          <Pressable
            key={c}
            onPress={() => setCurrent(c)}
            style={[styles.tab, c === current && styles.tabOn]}>
            <RNText style={styles.tabText}>{c}</RNText>
          </Pressable>
        ))}
      </View>
      <RNText style={styles.caption}>{LABELS[current]}</RNText>
      <Host style={styles.host}>
        {current === 'list' ? (
          // The issue: no width on the Column, so since @expo/ui 58.0.23 it lays out 0 wide on iOS.
          <Column>
            <List>
              <ListItem>Row 1</ListItem>
              <ListItem>Row 2</ListItem>
              <ListItem>Row 3</ListItem>
            </List>
          </Column>
        ) : (
          // Expected before and after the fix: the Column stays as wide as its text,
          // the Spacer does not stretch it to the Host width.
          <Column alignment="start" style={styles.spacerColumn}>
            <Text>Top of the column</Text>
            <Spacer flexible />
            <Text>Bottom of the column</Text>
          </Column>
        )}
      </Host>
    </View>
  );
}
