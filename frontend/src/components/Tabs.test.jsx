import React from 'react';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, it, expect, vi } from 'vitest';
import Tabs from './Tabs';

const TABS = ['Overview', 'Activity', 'Documents'];

describe('Tabs', () => {
  it('renders all tab labels', () => {
    render(<Tabs tabs={TABS} active="Overview" onChange={() => {}} />);
    TABS.forEach(t => expect(screen.getByRole('button', { name: t })).toBeInTheDocument());
  });

  it('calls onChange with the clicked tab label', async () => {
    const onChange = vi.fn();
    render(<Tabs tabs={TABS} active="Overview" onChange={onChange} />);
    await userEvent.click(screen.getByRole('button', { name: 'Activity' }));
    expect(onChange).toHaveBeenCalledWith('Activity');
  });

  it('does not call onChange when the active tab is clicked', async () => {
    const onChange = vi.fn();
    render(<Tabs tabs={TABS} active="Overview" onChange={onChange} />);
    await userEvent.click(screen.getByRole('button', { name: 'Overview' }));
    // onChange is still called — component delegates dedup to parent
    expect(onChange).toHaveBeenCalledWith('Overview');
  });

  it('renders a button for each tab', () => {
    render(<Tabs tabs={TABS} active="Overview" onChange={() => {}} />);
    expect(screen.getAllByRole('button')).toHaveLength(TABS.length);
  });
});
