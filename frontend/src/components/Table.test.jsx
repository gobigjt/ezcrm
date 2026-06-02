import React from 'react';
import { render, screen } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import Table from './Table';

const COLS = ['Name', 'Status', 'Amount'];

describe('Table', () => {
  it('renders column headers', () => {
    render(<Table cols={COLS} rows={[]} />);
    COLS.forEach(col => {
      expect(screen.getByText(col)).toBeInTheDocument();
    });
  });

  it('shows empty state message when rows is empty', () => {
    render(<Table cols={COLS} rows={[]} empty="No leads found" />);
    expect(screen.getByText('No leads found')).toBeInTheDocument();
  });

  it('shows default empty message when empty prop is omitted', () => {
    render(<Table cols={COLS} rows={[]} />);
    expect(screen.getByText('No records found')).toBeInTheDocument();
  });

  it('renders row data', () => {
    const rows = [
      ['Alice', 'New', '$1,000'],
      ['Bob', 'Closed', '$2,500'],
    ];
    render(<Table cols={COLS} rows={rows} />);
    expect(screen.getByText('Alice')).toBeInTheDocument();
    expect(screen.getByText('Bob')).toBeInTheDocument();
    expect(screen.getByText('$1,000')).toBeInTheDocument();
    expect(screen.getByText('$2,500')).toBeInTheDocument();
  });

  it('renders — for null/undefined cells', () => {
    render(<Table cols={COLS} rows={[[null, undefined, 'ok']]} />);
    const dashes = screen.getAllByText('—');
    expect(dashes).toHaveLength(2);
  });

  it('does not show empty state when rows are present', () => {
    render(<Table cols={COLS} rows={[['Alice', 'New', '$1,000']]} empty="No records found" />);
    expect(screen.queryByText('No records found')).not.toBeInTheDocument();
  });
});
