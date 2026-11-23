// Hammerspoon 2's CommonJS require(), which hammerspoon.d.ts doesn't declare.
// TypeScript's own `import` compiles to calls to it.
declare function require(path: string): unknown;
