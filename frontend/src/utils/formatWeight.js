/**
 * Auto-converts weight (stored in kg) to the most readable unit:
 *   < 1 kg   → grams   (e.g. 500 g)
 *   1–999 kg → kg      (e.g. 3.200 kg)
 *   ≥ 1000kg → tonnes  (e.g. 1.171 t)
 * Returns '—' for zero / null.
 */
export function formatWeight(kg) {
  const v = Number(kg || 0);
  if (v <= 0) return '—';
  if (v < 1)    return `${(v * 1000).toFixed(0)} g`;
  if (v < 1000) return `${v.toLocaleString('en-IN', { minimumFractionDigits: 3, maximumFractionDigits: 3 })} kg`;
  return `${(v / 1000).toLocaleString('en-IN', { minimumFractionDigits: 3, maximumFractionDigits: 3 })} t`;
}
