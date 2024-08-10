export function arraify<T>(value: undefined | T | Array<T>): Array<T> {
	if (value === undefined) {
		return []
	} else if (Array.isArray(value)) {
		return value
	} else {
		return [value]
	}
}
