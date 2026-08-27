import { Subscription } from '../types';

export function exportSubscriptionsToCSV(subscriptions: Subscription[]): string {
  const headers = ['Name', 'Amount', 'Currency', 'Category', 'Cycle', 'StartDate', 'Status', 'Notes'];
  
  const rows = subscriptions.map((sub) => {
    return [
      escapeCSVField(sub.name),
      sub.amount.toString(),
      escapeCSVField(sub.currency || 'EUR'),
      escapeCSVField(String(sub.category || 'General')),
      escapeCSVField(String(sub.cycle || 'Monthly')),
      sub.startDate,
      sub.status || 'active',
      escapeCSVField(sub.notes || '')
    ].join(',');
  });

  return [headers.join(','), ...rows].join('\n');
}

export function parseSubscriptionsFromCSV(csvContent: string): Subscription[] {
  const lines = csvContent.trim().split(/\r?\n/);
  if (lines.length < 2) return [];

  const headers = lines[0]?.split(',').map((h) => h.trim().toLowerCase()) || [];
  const nameIdx = headers.findIndex((h) => h.includes('name') || h.includes('nom'));
  const amountIdx = headers.findIndex((h) => h.includes('amount') || h.includes('montant') || h.includes('prix'));
  const categoryIdx = headers.findIndex((h) => h.includes('category') || h.includes('catégorie'));
  const cycleIdx = headers.findIndex((h) => h.includes('cycle') || h.includes('frequence') || h.includes('fréquence'));
  const dateIdx = headers.findIndex((h) => h.includes('start') || h.includes('date'));
  const notesIdx = headers.findIndex((h) => h.includes('note'));

  const results: Subscription[] = [];

  for (let i = 1; i < lines.length; i++) {
    const rawLine = lines[i]?.trim();
    if (!rawLine) continue;

    const fields = parseCSVLine(rawLine);
    const name = nameIdx >= 0 ? fields[nameIdx] : fields[0];
    const rawAmount = amountIdx >= 0 ? fields[amountIdx] : fields[1];
    const amount = parseFloat(rawAmount?.replace(/[^0-9\.\,]/g, '').replace(',', '.') || '0');

    if (!name || isNaN(amount) || amount <= 0) continue;

    const category = (categoryIdx >= 0 && fields[categoryIdx]) ? fields[categoryIdx] : 'General';
    const cycle = (cycleIdx >= 0 && fields[cycleIdx]) ? fields[cycleIdx] : 'Monthly';
    const startDate = (dateIdx >= 0 && fields[dateIdx] && /^\d{4}-\d{2}-\d{2}/.test(fields[dateIdx]))
      ? fields[dateIdx]!
      : new Date().toISOString().split('T')[0]!;

    const notes = (notesIdx >= 0 && fields[notesIdx]) ? fields[notesIdx] : '';

    results.push({
      id: `imported-${Date.now()}-${i}`,
      name: name.trim(),
      amount,
      category,
      cycle,
      startDate,
      notes,
      currency: 'EUR',
      currencySymbol: '€',
      status: 'active'
    });
  }

  return results;
}

function escapeCSVField(field: string): string {
  if (field.includes(',') || field.includes('"') || field.includes('\n')) {
    return `"${field.replace(/"/g, '""')}"`;
  }
  return field;
}

function parseCSVLine(line: string): string[] {
  const fields: string[] = [];
  let current = '';
  let inQuotes = false;

  for (let i = 0; i < line.length; i++) {
    const char = line[i];
    if (char === '"') {
      if (inQuotes && line[i + 1] === '"') {
        current += '"';
        i++;
      } else {
        inQuotes = !inQuotes;
      }
    } else if (char === ',' && !inQuotes) {
      fields.push(current.trim());
      current = '';
    } else {
      current += char;
    }
  }
  fields.push(current.trim());
  return fields;
}
