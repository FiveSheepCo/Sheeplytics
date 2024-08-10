export function arraify<T>(value: undefined | T | Array<T>): Array<T> {
	if (value === undefined) {
		return []
	}
	if (Array.isArray(value)) {
		return value
	}
	return [value]
}
