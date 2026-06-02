import React from 'react';
import { render, screen, act } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { renderHook } from '@testing-library/react';
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { ToastContainer, useToastState } from './Toast';

// ── ToastContainer ────────────────────────────────────────────────────────────

describe('ToastContainer', () => {
  it('renders nothing when toasts array is empty', () => {
    const { container } = render(<ToastContainer toasts={[]} />);
    expect(container.firstChild).toBeNull();
  });

  it('renders a toast message', () => {
    const toasts = [{ id: 1, message: 'Saved successfully', type: 'success', position: 'bottom-right' }];
    render(<ToastContainer toasts={toasts} />);
    expect(screen.getByText('Saved successfully')).toBeInTheDocument();
  });

  it('renders multiple toasts', () => {
    const toasts = [
      { id: 1, message: 'First toast', type: 'success', position: 'bottom-right' },
      { id: 2, message: 'Second toast', type: 'error', position: 'bottom-right' },
    ];
    render(<ToastContainer toasts={toasts} />);
    expect(screen.getByText('First toast')).toBeInTheDocument();
    expect(screen.getByText('Second toast')).toBeInTheDocument();
  });

  it('renders action buttons when provided', () => {
    const toasts = [{
      id: 1,
      message: 'Delete this item?',
      type: 'warning',
      position: 'top-center',
      actions: [
        { label: 'Cancel', variant: 'secondary', onClick: vi.fn() },
        { label: 'Delete', variant: 'danger', onClick: vi.fn() },
      ],
    }];
    render(<ToastContainer toasts={toasts} />);
    expect(screen.getByRole('button', { name: 'Cancel' })).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Delete' })).toBeInTheDocument();
  });

  it('calls action onClick when action button is clicked', async () => {
    const handleClick = vi.fn();
    const toasts = [{
      id: 1,
      message: 'Confirm?',
      type: 'warning',
      position: 'top-center',
      actions: [{ label: 'Confirm', variant: 'primary', onClick: handleClick }],
    }];
    render(<ToastContainer toasts={toasts} />);
    await userEvent.click(screen.getByRole('button', { name: 'Confirm' }));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });
});

// ── useToastState ─────────────────────────────────────────────────────────────

describe('useToastState', () => {
  beforeEach(() => { vi.useFakeTimers(); });
  afterEach(() => { vi.useRealTimers(); });

  it('starts with no toasts', () => {
    const { result } = renderHook(() => useToastState());
    expect(result.current.toasts).toHaveLength(0);
  });

  it('adds a toast when show() is called', () => {
    const { result } = renderHook(() => useToastState());
    act(() => { result.current.show('Hello!', 'success'); });
    expect(result.current.toasts).toHaveLength(1);
    expect(result.current.toasts[0].message).toBe('Hello!');
    expect(result.current.toasts[0].type).toBe('success');
  });

  it('defaults type to success', () => {
    const { result } = renderHook(() => useToastState());
    act(() => { result.current.show('Hi'); });
    expect(result.current.toasts[0].type).toBe('success');
  });

  it('auto-dismisses toast after 3000ms by default', () => {
    const { result } = renderHook(() => useToastState());
    act(() => { result.current.show('Auto dismiss'); });
    expect(result.current.toasts).toHaveLength(1);
    act(() => { vi.advanceTimersByTime(3000); });
    expect(result.current.toasts).toHaveLength(0);
  });

  it('respects custom durationMs', () => {
    const { result } = renderHook(() => useToastState());
    act(() => { result.current.show('Custom', 'info', { durationMs: 1000 }); });
    act(() => { vi.advanceTimersByTime(999); });
    expect(result.current.toasts).toHaveLength(1);
    act(() => { vi.advanceTimersByTime(1); });
    expect(result.current.toasts).toHaveLength(0);
  });

  it('does not auto-dismiss when durationMs is false', () => {
    const { result } = renderHook(() => useToastState());
    act(() => { result.current.show('Sticky', 'info', { durationMs: false }); });
    act(() => { vi.advanceTimersByTime(10000); });
    expect(result.current.toasts).toHaveLength(1);
  });

  it('places toast at top-center when position is specified', () => {
    const { result } = renderHook(() => useToastState());
    act(() => { result.current.show('Top!', 'warning', { position: 'top-center', actions: [{ label: 'OK', onClick: () => {} }] }); });
    expect(result.current.toasts[0].position).toBe('top-center');
  });
});
