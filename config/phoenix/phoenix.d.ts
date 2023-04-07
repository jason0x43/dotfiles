export {};

declare global {
	class Phoenix {
		static log(...args: unknown[]): void;
		static reload(): void;
		static set(prefs: Record<string, unknown>): void;
		static notify(message: string): void;
		private constructor();
	}

	interface Identifiable {
		hash(): number;
		isEqual(other: unknown): boolean;
	}

	interface Key extends Identifiable {
		key: string;
		modifiers: string[];

		isEnabled(): boolean;
		enable(): boolean;
		disable(): boolean;
	}

	interface KeyStatic {
		on(key: string, modifiers: string[], callback: () => void): number;
		once(key: string, modifiers: string[], callback: () => void): void;
		off(id: number): void;

		new (key: string, modifiers: string[], callback: () => void): KeyInstance;
	}

	const Key: KeyStatic;

	interface Event extends Identifiable {
		name: string;
		constructor(event: string, callback: () => void);
		disable(): void;
	}

	interface EventStatic {
		on(event: string, callback: () => void): number;
		once(event: string, callback: () => void): void;
		off(id: number): void;

		new (event: string, callback: () => void): Event;
	}

	const Event: EventStatic;

	interface StorageStatic {
		set(key: string, value: unknown): void;
		get(key: string): unknown;
		remove(key: string): void;
	}

	const Storage: StorageStatic;

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

	interface Space extends Identifiable, Iterable<Space> {
		isNormal(): boolean;
		isFullScreen(): boolean;
		screens(): Screen[];
		windows(optionals?: Record<string, unknown>): Window[];
		addWindows(windows: Window[]): void;
		removeWindows(windows: Window[]): void;
		moveWindows(windows: Window[]): void;
	}

	interface SpaceStatic {
		active(): SpaceInstance;
		all(): SpaceInstance[];
	}

	const Space: SpaceStatic;

	interface Screen extends Identifiable, Iterable<Screen> {
		identifier(): string;
		frame(): Rectangle;
		visibleFrame(): Rectangle;
		flippedFrame(): Rectangle;
		flippedVisibleFrame(): Rectangle;
		currentSpace(): Space;
		spaces(): Space[];
		windows(optionals?: Record<string, unknown>): Window[];
	}

	interface ScreenStatic { 
		main(): Screen;
		all(): Screen[];
	}

	const Screen: ScreenStatic;

	interface ImageStatic {
		fromFile(path: string): Identifiable;
	}

	const Image: ImageStatic;

	interface App extends Identifiable {
		processIdentifier(): number;
		bundleIdentifier(): string;
		name(): string;
		icon(): Image;
		isActive(): boolean;
		isHidden(): boolean;
		isTerminated(): boolean;
		mainWindow(): Window;
		windows(optionals?: Record<string, unknown>): Window[];
		activate(): boolean;
		focus(): boolean;
		show(): boolean;
		hide(): boolean;
		terminate(optionals?: Record<string, unknown>): boolean;
	}

	interface AppStatic {
		get(appName: string): App;
		launch(appName: string, optionals?: Record<string, unknown>): App;
		focused(): App;
		all(): App[];
	}

	const App: AppStatic;

	interface Window extends Identifiable {
		others(optionals?: Record<string, unknown>): Window[];
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
	}

	interface WindowStatic {
		focused(): Window;
		at(point: Point): Window;
		all(optionals?: Record<string, unknown>): Window[];
		recent(): Window[];
	}

	const Window: WindowStatic;

	interface Modal {
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

	interface ModalStatic {
		build(properties: Record<string, unknown>): Modal;
		new (): Modal;
	}

	const Modal: ModalStatic;

	interface TaskResult {
		status: number;
		output: string;
		error: string;
	}

	interface Task extends Identifiable, Partial<TaskResult> {
		terminate(): void;
	}

	interface TaskStatic {
		run(
			path: string,
			arguments: string[],
			callback?: (result: TaskResult) => void
		): number;
		terminate(identifier: number): void;

		new (
			path: string,
			arguments: string[],
			callback?: (result: TaskResult) => void
		): Task;
	}

	const Task: TaskStatic;

	function clearTimeout(id: number | null): void;
	function setTimeout(callback: () => void, timeout: number): number;
}
