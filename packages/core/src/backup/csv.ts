import { Subscription } from '../types';
import { subscriptionSchema } from '../validation/schemas';

function escapeField(value: string): string {
  // Neutralize spreadsheet formulas, including leading control characters.
  const safe = /^[\s]*[=+@-]|^[\t\r\n]/.test(value) ? `'${value}` : value;
  return `"${safe.replace(/"/g, '""')}"`;
}
export function exportSubscriptionsToCSV(subscriptions: Subscription[]): string {
  return ['Name,Amount,Currency,Category,Cycle,StartDate,Status,Notes', ...subscriptions.map(s =>
    [s.name, String(s.amount), s.currency || 'EUR', s.category || 'General', s.cycle || 'Monthly', s.startDate, s.status || 'active', s.notes || ''].map(escapeField).join(',')
  )].join('\r\n');
}

function readRows(text: string): string[][] {
  const rows: string[][] = []; let row: string[] = []; let field = ''; let quoted = false;
  for (let i = 0; i < text.length; i++) {
    const c = text[i];
    if (c === '"') {
      if (quoted && text[i + 1] === '"') { field += '"'; i++; }
      else quoted = !quoted;
    } else if (!quoted && (c === ',' || c === '\n' || c === '\r')) {
      row.push(field); field = '';
      if (c !== ',') { if (row.some(x => x.trim())) rows.push(row); row = []; if (c === '\r' && text[i + 1] === '\n') i++; }
    } else field += c;
  }
  if (quoted) throw new Error('Unclosed CSV quote');
  row.push(field); if (row.some(x => x.trim())) rows.push(row);
  return rows;
}
export function parseSubscriptionsFromCSV(csvContent: string): Subscription[] {
  if (csvContent.length > 5 * 1024 * 1024) throw new Error('CSV too large');
  const rows = readRows(csvContent.replace(/^\uFEFF/, ''));
  const headers = rows.shift()?.map(x => x.trim().toLowerCase()) || [];
  const index = (names: string[]) => headers.findIndex(x => names.includes(x));
  const name = index(['name','nom']), amount = index(['amount','montant','prix']);
  if (name < 0 || amount < 0) throw new Error('Missing name or amount column');
  if (rows.length > 10000) throw new Error('Too many rows');
  return rows.map((row, i) => {
    const field = (names: string[], fallback: string) => row[index(names)] || fallback;
    const currency = field(['currency','devise'], 'EUR');
    return subscriptionSchema.parse({
      id: `csv-${i}-${encodeURIComponent(row[name] || '').slice(0, 60)}`,
      name: row[name]?.trim(), amount: Number(row[amount]?.trim().replace(',', '.')),
      currency, currencySymbol: currency === 'EUR' ? '€' : currency === 'USD' ? '$' : currency === 'GBP' ? '£' : currency,
      category: field(['category','catégorie'], 'General'), cycle: field(['cycle','frequence','fréquence'], 'Monthly'),
      startDate: field(['startdate','date'], new Date().toISOString().slice(0, 10)),
      status: field(['status','statut'], 'active'), notes: field(['notes','note'], '')
    });
  });
}
