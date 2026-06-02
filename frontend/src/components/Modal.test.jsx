import React from 'react';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, it, expect, vi } from 'vitest';
import Modal from './Modal';

describe('Modal', () => {
  it('renders the title', () => {
    render(<Modal title="Add Lead" onClose={() => {}}><p>body</p></Modal>);
    expect(screen.getByText('Add Lead')).toBeInTheDocument();
  });

  it('renders children in the body', () => {
    render(<Modal title="Test" onClose={() => {}}><span>Modal content here</span></Modal>);
    expect(screen.getByText('Modal content here')).toBeInTheDocument();
  });

  it('renders a close button', () => {
    render(<Modal title="Test" onClose={() => {}}>body</Modal>);
    expect(screen.getByRole('button')).toBeInTheDocument();
  });

  it('calls onClose when the × button is clicked', async () => {
    const onClose = vi.fn();
    render(<Modal title="Test" onClose={onClose}>body</Modal>);
    await userEvent.click(screen.getByRole('button'));
    expect(onClose).toHaveBeenCalledTimes(1);
  });
});
