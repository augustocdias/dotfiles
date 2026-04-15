import { tool } from "@opencode-ai/plugin"

export default tool({
  description: `Perform date calculations and formatting using the Unix date utility.

**Formatting**: Use the format parameter with standard Unix date format specifiers
(e.g., "%Y-%m-%d" for 2025-01-15, "%A, %d. %B %Y at %H:%M:%S" for "Tuesday, 26. August 2025 at 20:36:19").

**Operations**: Use the operations array to add or subtract time from the current date.
Each operation follows the format [+|-][NUMBER][METRIC]:
- + to add, - to subtract
- NUMBER: the value to add/subtract
- METRIC: y (year), m (month), w (week), d (day), H (hour), M (minute), S (second)

Examples:
- Get tomorrow: operations: ["+1d"]
- Get date 3 months ago: operations: ["-3m"]
- Get date 2 weeks and 3 days from now: operations: ["+2w", "+3d"]`,
  args: {
    format: tool.schema
      .string()
      .optional()
      .describe(
        'Date format string for the Unix date utility. Example: "%A, %d. %B %Y at %H:%M:%S"',
      ),
    operations: tool.schema
      .array(
        tool.schema
          .string()
          .describe(
            "Operation in the format [+|-][NUMBER][METRIC] where METRIC is y|m|w|d|H|M|S",
          ),
      )
      .optional()
      .describe("Array of date arithmetic operations to apply"),
  },
  async execute(args) {
    const cmdArgs = ["date"]
    for (const op of args.operations ?? []) {
      cmdArgs.push(`-v${op}`)
    }
    if (args.format) {
      cmdArgs.push(`+${args.format}`)
    }
    const result = await Bun.$`${cmdArgs}`.text()
    return result.trim()
  },
})
