// Hammerspoon 2 has no hs.logger, so this is a thin prefixing wrapper around
// console.*.

export interface Logger {
	d(message: string): void;
	i(message: string): void;
	w(message: string): void;
	e(message: string): void;
}

export function createLogger(name: string): Logger {
	const prefix = `[${name}]`;
	return {
		d: (message) => console.debug(`${prefix} ${message}`),
		i: (message) => console.info(`${prefix} ${message}`),
		w: (message) => console.warn(`${prefix} ${message}`),
		e: (message) => console.error(`${prefix} ${message}`),
	};
}
