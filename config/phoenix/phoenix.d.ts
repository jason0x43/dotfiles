export {};

declare global {
  declare class Phoenix {
    static log(...args: unknown[]): void;
    static reload(): void;
    static set(prefs: Record<string, unknown>): void;
    static notify(message: string): void;
    private constructor();
  }

  declare class Key {
    static on(key: string, modifiers: string[], callback: () => void): number;
    static once(key: string, modifiers: string[], callback: () => void): void;
    static off(id: number): void;

    key: string;
    modifiers: string[];

    constructor(key: string, modifiers: string[], callback: () => void);

    isEnabled(): boolean;
    enable(): boolean;
    disable(): boolean;

    // Identifiable
    hash(): number;
    isEqual(other: unknown): boolean;
  }

  declare class Event {
    name: string;

    static on(event: string, callback: () => void): number;
    static once(event: string, callback: () => void): void;
    static off(id: number): void;

    constructor(event: string, callback: () => void);

    disable(): void;

    // Identifiable
    hash(): number;
    isEqual(other: unknown): boolean;
  }

  declare class Storage {
    static set(key: string, value: unknown): void;
    static get(key: string): unkown;
    static remove(key: string): void;
    private constructor();
  }

  interface Point {
    x: number;
    y: number;
  }

  interface Size {
    width: number;
    height: number;
  }

  type Rectangle = Point & Size;

  interface Iterable<T> {
    next(): T;
    previous(): T;
  }

  declare class Space {
    static active(): Space;
    static all(): Space[];

    private constructor();

    isNormal(): boolean;
    isFullScreen(): boolean;
    screens(): Screen[];
    windows(optionals?: Record<string, unknown>): Window[];
    addWindows(windows: Window[]): void;
    removeWindows(windows: Window[]): void;

    // Identifiable
    hash(): number;
    isEqual(other: unknown): boolean;

    // Iterable
    next(): Space;
    previous(): Space;
  }

  declare class Screen {
    static main(): Screen;
    static all(): Screen[];

    private constructor();

    identifier(): string;
    frame(): Rectangle;
    visibleFrame(): Rectangle;
    flippedFrame(): Rectangle;
    flippedVisibleFrame(): Rectangle;
    currentSpace(): Space;
    spaces(): Space[];
    windows(optionals?: Record<string, unknown>): Window[];

    // Identifiable
    hash(): number;
    isEqual(other: unknown): boolean;

    // Iterable
    next(): Screen;
    previous(): Screen;
  }

  declare class Image {
    static fromFile(path: string): Image;
    private constructor();

    // Identifiable
    hash(): number;
    isEqual(other: unknown): boolean;
  }

  declare class App {
    static get(appName: string): App;
    static launch(appName: string, optionals?: Record<string, unkown>): App;
    static focused(): App;
    static all(): App[];

    processIdentifier(): number;
    bundleIdentifier(): string;
    name(): string;
    icon(): Image;
    isActive(): boolean;
    isHidden(): boolean;
    isTerminated(): boolean;
    mainWindow(): Window;
    windows(optionals?: Record<string, unkown>): Window[];
    activate(): boolean;
    focus(): boolean;
    show(): boolean;
    hide(): boolean;
    terminate(optionals?: Record<string, unkown>): boolean;

    // Identifiable
    hash(): number;
    isEqual(other: unknown): boolean;
  }

  declare class Window {
    static focused(): Window;
    static at(point: Point): Window;
    static all(optionals?: Record<string, unknown>): Window[];
    static recent(): Window[];

    private constructor();

    others(optionals?: Record<string, unkown>): Window[];
    title(): string;
    isMain(): boolean;
    isNormal(): boolean;
    isFullScreen(): boolean;
    isMinimized(): boolean;
    isVisible(): boolean;
    app(): App;
    screen(): Screen;
    spaces(): Space[];
    topLeft(): Point;
    size(): Size;
    frame(): Rectangle;
    setTopLeft(point: Point): boolean;
    setSize(size: Size): boolean;
    setFrame(frame: Rectangle): boolean;
    setFullScreen(value: boolean): boolean;
    maximize(): boolean;
    minimize(): boolean;
    unminimize(): boolean;
    neighbors(direction: string): Window[];
    raise(): boolean;
    focus(): boolean;
    focusClosestNeighbor(direction: string): boolean;
    close(): boolean;

    // Identifiable
    hash(): number;
    isEqual(other: unknown): boolean;
  }

  declare class Modal {
    static build(properties: Record<string, unknown>): Modal;

    origin: Point;
    duration: number;
    animationDuration: number;
    weight: number;
    appearance: string;
    icon: Image;
    text: string;

    constructor();

    frame(): Rectangle;
    show(): void;
    close(): void;
  }

  function clearTimeout(id: number | null): void;
  function setTimeout(callback: () => void, timeout: number): number;
}
