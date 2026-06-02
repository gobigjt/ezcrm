import React from 'react';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, it, expect, vi } from 'vitest';
import { Field, FormActions } from './FormField';

describe('Field', () => {
  it('renders the label', () => {
    render(<Field label="Email"><input /></Field>);
    expect(screen.getByText('Email')).toBeInTheDocument();
  });

  it('renders children inside the field', () => {
    render(<Field label="Phone"><input placeholder="Enter phone" /></Field>);
    expect(screen.getByPlaceholderText('Enter phone')).toBeInTheDocument();
  });
});

describe('FormActions', () => {
  it('renders Cancel and Save buttons by default', () => {
    render(<FormActions onCancel={() => {}} />);
    expect(screen.getByRole('button', { name: 'Cancel' })).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Save' })).toBeInTheDocument();
  });

  it('renders custom submit label', () => {
    render(<FormActions onCancel={() => {}} submitLabel="Create Lead" />);
    expect(screen.getByRole('button', { name: 'Create Lead' })).toBeInTheDocument();
  });

  it('shows Saving… and disables submit when loading', () => {
    render(<FormActions onCancel={() => {}} loading />);
    const submitBtn = screen.getByRole('button', { name: 'Saving…' });
    expect(submitBtn).toBeDisabled();
  });

  it('calls onCancel when Cancel is clicked', async () => {
    const onCancel = vi.fn();
    render(<FormActions onCancel={onCancel} />);
    await userEvent.click(screen.getByRole('button', { name: 'Cancel' }));
    expect(onCancel).toHaveBeenCalledTimes(1);
  });
});
