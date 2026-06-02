import '@testing-library/jest-dom';
import React from 'react';
// @vitejs/plugin-react v6 (Rolldown-based) doesn't apply the automatic JSX
// runtime transform inside Vitest's pipeline; exposing React globally lets
// the classic transform work without touching each source file.
global.React = React;
