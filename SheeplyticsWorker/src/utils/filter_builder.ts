export default class FilterBuilder {
	private whereClauses: Array<string> = []
	private queryBindings: Array<string> = []

	equalsAny(column: string, values: Array<string>): this {
		if (values.length === 0) {
			return this
		}
		this.queryBindings.push(...values)
		this.whereClauses.push(`(${values.map(_ => `${column} = ?`).join(' OR ')})`)
		return this
	}

	between(column: string, start: string | undefined, end: string | undefined): this {
		if (!start && !end) {
			return this
		}
		const clauses: Array<string> = []
		if (start) {
			clauses.push(`${column} >= ?`)
			this.queryBindings.push(start)
		}
		if (end) {
			clauses.push(`${column} <= ?`)
			this.queryBindings.push(end)
		}
		this.whereClauses.push(`(${clauses.join(' AND ')})`)
		return this
	}

	build(): { whereClause: string, queryBindings: Array<string> } {
		const whereClause = this.whereClauses.join(' AND ')
		return {
			whereClause,
			queryBindings: this.queryBindings
		}
	}
}
