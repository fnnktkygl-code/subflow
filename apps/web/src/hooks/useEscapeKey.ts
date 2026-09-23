'use client';
import { useEffect, useRef } from 'react';
const modalStack: symbol[] = [];
/** Keep keyboard focus inside the topmost open dialog and restore it on close. */
export function useEscapeKey(isOpen: boolean, onClose: () => void) {
  const closeRef = useRef(onClose);
  closeRef.current = onClose;
  useEffect(() => {
    if (!isOpen) return;
    const token = Symbol('dialog');
    modalStack.push(token);
    const previous = document.activeElement as HTMLElement | null;
    const dialogs = document.querySelectorAll<HTMLElement>('[role="dialog"]');
    const dialog = dialogs[dialogs.length - 1];
    const focusable = () => Array.from(dialog?.querySelectorAll<HTMLElement>('button:not([disabled]), a[href], input:not([disabled]), select:not([disabled]), textarea:not([disabled]), [tabindex="0"]') || []).filter(el => el.getClientRects().length > 0);
    focusable()[0]?.focus();
    const onKey = (event: KeyboardEvent) => {
      if (modalStack[modalStack.length - 1] !== token) return;
      if (event.key === 'Escape') { event.preventDefault(); event.stopImmediatePropagation(); closeRef.current(); }
      if (event.key === 'Tab' && dialog) {
        const elements = focusable(); const first = elements[0], last = elements[elements.length - 1];
        if (!first) { event.preventDefault(); return; }
        if (event.shiftKey && (document.activeElement === first || !dialog.contains(document.activeElement))) { event.preventDefault(); last?.focus(); }
        else if (!event.shiftKey && (document.activeElement === last || !dialog.contains(document.activeElement))) { event.preventDefault(); first.focus(); }
      }
    };
    window.addEventListener('keydown', onKey, true);
    return () => { modalStack.splice(modalStack.indexOf(token), 1); window.removeEventListener('keydown', onKey, true); if (previous?.isConnected) previous.focus(); };
  }, [isOpen]);
}
