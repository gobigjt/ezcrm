import { describe, it, expect } from 'vitest';
import { formatWeight } from './formatWeight';

describe('formatWeight', () => {
  it('returns — for zero', () => {
    expect(formatWeight(0)).toBe('—');
  });

  it('returns — for null', () => {
    expect(formatWeight(null)).toBe('—');
  });

  it('returns — for negative values', () => {
    expect(formatWeight(-5)).toBe('—');
  });

  it('returns grams for values less than 1 kg', () => {
    expect(formatWeight(0.5)).toBe('500 g');
    expect(formatWeight(0.1)).toBe('100 g');
    expect(formatWeight(0.001)).toBe('1 g');
  });

  it('returns kg for values 1–999 kg', () => {
    expect(formatWeight(1)).toBe('1.000 kg');
    expect(formatWeight(3.2)).toBe('3.200 kg');
    expect(formatWeight(999)).toBe('999.000 kg');
  });

  it('returns tonnes for values >= 1000 kg', () => {
    expect(formatWeight(1000)).toBe('1.000 t');
    expect(formatWeight(1171)).toBe('1.171 t');
    expect(formatWeight(5000)).toBe('5.000 t');
  });
});
