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
