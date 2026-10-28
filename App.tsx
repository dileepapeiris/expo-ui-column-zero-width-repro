import { Column, Host, List, ListItem, Spacer, Text } from '@expo/ui';
import { useEffect, useState } from 'react';
import { Pressable, StyleSheet, Text as RNText, View } from 'react-native';

type Case = 'list' | 'spacer';
