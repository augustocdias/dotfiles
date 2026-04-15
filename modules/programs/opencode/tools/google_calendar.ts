import { tool } from "@opencode-ai/plugin"

export default tool({
  description: `Query and search Google Calendar events using gcalcli. All operations are read-only.

**Available Actions**:
- list_calendars: Show all available calendars
- agenda: Display upcoming events for the next N days (default: 7)
- list_today: Show all events for today
- search: Search for events by keyword (requires query parameter)

Use this tool to check schedules, find meetings, see available calendars, or get event details including meeting links and descriptions.`,
  args: {
    action: tool.schema
      .enum(["list_calendars", "agenda", "list_today", "search"])
      .describe("Action to perform"),
    query: tool.schema
      .string()
      .optional()
      .describe('Search query (required for "search" action)'),
    days: tool.schema
      .number()
      .optional()
      .describe('Number of days to show for "agenda" action (default: 7)'),
    calendar: tool.schema
      .string()
      .optional()
      .describe("Specific calendar name to query"),
  },
  async execute(args) {
    const cmdArgs = ["gcalcli"]

    switch (args.action) {
      case "list_calendars":
        cmdArgs.push("list")
        break

      case "agenda": {
        const days = args.days ?? 7
        cmdArgs.push("agenda", "--details", "all")
        if (args.calendar) {
          cmdArgs.push("--calendar", args.calendar)
        }
        cmdArgs.push("today", `${days}d`)
        break
      }

      case "list_today":
        cmdArgs.push("agenda", "--details", "all")
        if (args.calendar) {
          cmdArgs.push("--calendar", args.calendar)
        }
        cmdArgs.push("today")
        break

      case "search":
        if (!args.query) {
          return "Error: query is required for search action"
        }
        cmdArgs.push("search", "--details", "all", args.query)
        if (args.calendar) {
          cmdArgs.push("--calendar", args.calendar)
        }
        break
    }

    try {
      const result = await Bun.$`${cmdArgs}`.text()
      return result
    } catch (error: unknown) {
      const msg = error instanceof Error ? error.message : String(error)
      if (/Authentication|credentials|OAuth|401|Access denied/i.test(msg)) {
        return "Authentication required. Run: gcalcli init"
      }
      if (/command not found|No such file or directory/i.test(msg)) {
        return "gcalcli not installed. Install it via your package manager."
      }
      return `gcalcli command failed: ${msg}`
    }
  },
})
