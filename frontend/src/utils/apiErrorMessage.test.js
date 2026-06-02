import { describe, it, expect } from 'vitest';
import { apiErrorMessage } from './apiErrorMessage';

describe('apiErrorMessage', () => {
  it('joins array messages with a space', () => {
    const err = { response: { data: { message: ['Name is required', 'Email is invalid'] } } };
    expect(apiErrorMessage(err)).toBe('Name is required Email is invalid');
  });

  it('returns string message from response data', () => {
    const err = { response: { data: { message: 'Unauthorized' } } };
    expect(apiErrorMessage(err)).toBe('Unauthorized');
  });

  it('falls back to err.message when no response data message', () => {
    const err = { message: 'Network Error' };
    expect(apiErrorMessage(err)).toBe('Network Error');
  });

  it('returns the default fallback when nothing is available', () => {
    expect(apiErrorMessage({})).toBe('Something went wrong');
  });

  it('returns custom fallback string', () => {
    expect(apiErrorMessage({}, 'Action failed')).toBe('Action failed');
  });

  it('handles null/undefined error gracefully', () => {
    expect(apiErrorMessage(null)).toBe('Something went wrong');
    expect(apiErrorMessage(undefined)).toBe('Something went wrong');
  });

  it('ignores blank response message and falls through', () => {
    const err = { response: { data: { message: '   ' } }, message: 'Network Error' };
    expect(apiErrorMessage(err)).toBe('Network Error');
  });
});
