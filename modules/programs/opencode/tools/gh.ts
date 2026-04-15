import { tool } from "@opencode-ai/plugin"

async function runGh(args: string[]): Promise<string> {
  try {
    const result = await Bun.$`gh ${args}`.text()
    return result
  } catch (error: unknown) {
    const msg = error instanceof Error ? error.message : String(error)
    throw new Error(`gh command failed: ${msg}`)
  }
}

// ---------------------------------------------------------------------------
// Issues
// ---------------------------------------------------------------------------

export const issue_read = tool({
  description:
    "GitHub Issue read operations: list issues or view a specific issue",
  args: {
    action: tool.schema.enum(["list", "view"]).describe("Issue action"),
    number: tool.schema
      .string()
      .optional()
      .describe("Issue number (required for view)"),
    state: tool.schema
      .string()
      .optional()
      .describe("Filter by state: open, closed, all (for list)"),
    assignee: tool.schema
      .string()
      .optional()
      .describe("Filter by assignee (for list)"),
    label: tool.schema
      .string()
      .optional()
      .describe("Filter by label (for list)"),
    limit: tool.schema
      .string()
      .optional()
      .describe("Max results (for list, default: 30)"),
  },
  async execute(args) {
    const cmd = ["issue", args.action]
    if (args.action === "list") {
      if (args.state) cmd.push("--state", args.state)
      if (args.assignee) cmd.push("--assignee", args.assignee)
      if (args.label) cmd.push("--label", args.label)
      if (args.limit) cmd.push("--limit", args.limit)
    } else if (args.action === "view") {
      if (args.number) cmd.push(args.number)
    }
    return runGh(cmd)
  },
})

export const issue_write = tool({
  description:
    "GitHub Issue write operations: create, close, or reopen issues",
  args: {
    action: tool.schema
      .enum(["create", "close", "reopen"])
      .describe("Issue action"),
    number: tool.schema
      .string()
      .optional()
      .describe("Issue number (required for close, reopen)"),
    title: tool.schema
      .string()
      .optional()
      .describe("Issue title (required for create)"),
    body: tool.schema
      .string()
      .optional()
      .describe("Issue description (for create)"),
    assignee: tool.schema
      .string()
      .optional()
      .describe("Assignee username (for create)"),
    label: tool.schema
      .string()
      .optional()
      .describe("Label (for create)"),
  },
  async execute(args) {
    const cmd = ["issue", args.action]
    if (args.action === "create") {
      if (args.title) cmd.push("--title", args.title)
      if (args.body) cmd.push("--body", args.body)
      if (args.assignee) cmd.push("--assignee", args.assignee)
      if (args.label) cmd.push("--label", args.label)
    } else {
      if (args.number) cmd.push(args.number)
    }
    return runGh(cmd)
  },
})

// ---------------------------------------------------------------------------
// Pull Requests
// ---------------------------------------------------------------------------

export const pr_read = tool({
  description:
    "GitHub Pull Request read operations: list PRs or view a specific PR",
  args: {
    action: tool.schema.enum(["list", "view"]).describe("PR action"),
    number: tool.schema
      .string()
      .optional()
      .describe("PR number (required for view)"),
    state: tool.schema
      .string()
      .optional()
      .describe("Filter by state: open, closed, merged, all (for list)"),
    assignee: tool.schema
      .string()
      .optional()
      .describe("Filter by assignee (for list)"),
    label: tool.schema
      .string()
      .optional()
      .describe("Filter by label (for list)"),
    limit: tool.schema
      .string()
      .optional()
      .describe("Max results (for list, default: 30)"),
  },
  async execute(args) {
    const cmd = ["pr", args.action]
    if (args.action === "list") {
      if (args.state) cmd.push("--state", args.state)
      if (args.assignee) cmd.push("--assignee", args.assignee)
      if (args.label) cmd.push("--label", args.label)
      if (args.limit) cmd.push("--limit", args.limit)
    } else if (args.action === "view") {
      if (args.number) cmd.push(args.number)
    }
    return runGh(cmd)
  },
})

export const pr_write = tool({
  description:
    "GitHub Pull Request write operations: create, merge, close, reopen, ready, or draft PRs",
  args: {
    action: tool.schema
      .enum(["create", "merge", "close", "reopen", "ready", "draft"])
      .describe("PR action"),
    number: tool.schema
      .string()
      .optional()
      .describe(
        "PR number (required for merge, close, reopen, ready, draft)",
      ),
    title: tool.schema
      .string()
      .optional()
      .describe("PR title (required for create)"),
    body: tool.schema
      .string()
      .optional()
      .describe("PR description (for create)"),
    base: tool.schema
      .string()
      .optional()
      .describe("Base branch (for create, defaults to main)"),
    head: tool.schema
      .string()
      .optional()
      .describe("Head branch (for create, defaults to current branch)"),
    is_draft: tool.schema
      .boolean()
      .optional()
      .describe("Create as draft PR (for create)"),
    assignee: tool.schema
      .string()
      .optional()
      .describe("Assignee username (for create)"),
    label: tool.schema
      .string()
      .optional()
      .describe("Label (for create)"),
    merge_method: tool.schema
      .string()
      .optional()
      .describe("Merge method: merge, squash, rebase (for merge)"),
  },
  async execute(args) {
    const cmd = ["pr", args.action]
    if (args.action === "create") {
      if (args.title) cmd.push("--title", args.title)
      if (args.body) cmd.push("--body", args.body)
      if (args.base) cmd.push("--base", args.base)
      if (args.head) cmd.push("--head", args.head)
      if (args.is_draft) cmd.push("--draft")
      if (args.assignee) cmd.push("--assignee", args.assignee)
      if (args.label) cmd.push("--label", args.label)
    } else {
      if (args.number) cmd.push(args.number)
      if (args.action === "merge" && args.merge_method) {
        cmd.push(`--${args.merge_method}`)
      }
    }
    return runGh(cmd)
  },
})

// ---------------------------------------------------------------------------
// Workflows
// ---------------------------------------------------------------------------

export const workflow_read = tool({
  description:
    "GitHub Actions workflow read operations: list or view workflows",
  args: {
    action: tool.schema.enum(["list", "view"]).describe("Workflow action"),
    workflow: tool.schema
      .string()
      .optional()
      .describe("Workflow name or ID (required for view)"),
  },
  async execute(args) {
    const cmd = ["workflow", args.action]
    if (args.action === "view" && args.workflow) {
      cmd.push(args.workflow)
    }
    return runGh(cmd)
  },
})

export const workflow_write = tool({
  description: "GitHub Actions workflow write operations: trigger a workflow run",
  args: {
    workflow: tool.schema
      .string()
      .describe("Workflow name or ID to run"),
    ref: tool.schema
      .string()
      .optional()
      .describe("Git reference (branch/tag) for the run"),
    inputs: tool.schema
      .string()
      .optional()
      .describe("Workflow inputs as JSON string"),
  },
  async execute(args) {
    const cmd = ["workflow", "run", args.workflow]
    if (args.ref) cmd.push("--ref", args.ref)
    if (args.inputs) cmd.push("--json", args.inputs)
    return runGh(cmd)
  },
})

// ---------------------------------------------------------------------------
// Runs
// ---------------------------------------------------------------------------

export const run_read = tool({
  description:
    "GitHub Actions run read operations: list or view workflow runs",
  args: {
    action: tool.schema.enum(["list", "view"]).describe("Run action"),
    run_id: tool.schema
      .string()
      .optional()
      .describe("Run ID (required for view)"),
    workflow: tool.schema
      .string()
      .optional()
      .describe("Filter by workflow name/ID (for list)"),
    status: tool.schema
      .string()
      .optional()
      .describe(
        "Filter by status: completed, in_progress, queued (for list)",
      ),
    limit: tool.schema
      .string()
      .optional()
      .describe("Max results (for list, default: 20)"),
  },
  async execute(args) {
    const cmd = ["run", args.action]
    if (args.action === "list") {
      if (args.workflow) cmd.push("--workflow", args.workflow)
      if (args.status) cmd.push("--status", args.status)
      if (args.limit) cmd.push("--limit", args.limit)
    } else if (args.action === "view") {
      if (args.run_id) cmd.push(args.run_id)
    }
    return runGh(cmd)
  },
})

export const run_write = tool({
  description:
    "GitHub Actions run write operations: cancel or rerun a workflow run",
  args: {
    action: tool.schema
      .enum(["cancel", "rerun"])
      .describe("Run action"),
    run_id: tool.schema.string().describe("Run ID"),
  },
  async execute(args) {
    return runGh(["run", args.action, args.run_id])
  },
})

// ---------------------------------------------------------------------------
// Search
// ---------------------------------------------------------------------------

export const search = tool({
  description:
    "GitHub search operations: search repos, issues, PRs, or code",
  args: {
    type: tool.schema
      .enum(["repos", "issues", "prs", "code"])
      .describe("Search type"),
    query: tool.schema.string().describe("Search query string"),
    limit: tool.schema
      .string()
      .optional()
      .describe("Max results (default: 30)"),
    sort: tool.schema
      .string()
      .optional()
      .describe("Sort: updated, created, stars, forks (varies by type)"),
    order: tool.schema
      .string()
      .optional()
      .describe("Sort direction: asc, desc"),
  },
  async execute(args) {
    const cmd = ["search", args.type, args.query]
    if (args.limit) cmd.push("--limit", args.limit)
    if (args.sort) cmd.push("--sort", args.sort)
    if (args.order) cmd.push("--order", args.order)
    return runGh(cmd)
  },
})

// ---------------------------------------------------------------------------
// Status
// ---------------------------------------------------------------------------

export const status = tool({
  description:
    "GitHub status operations: auth status, user info, or activity feed",
  args: {
    type: tool.schema
      .enum(["activity", "user", "auth"])
      .describe("Status type"),
  },
  async execute(args) {
    switch (args.type) {
      case "activity":
        return runGh(["status"])
      case "user":
        return runGh(["api", "user"])
      case "auth":
        return runGh(["auth", "status"])
    }
  },
})

// ---------------------------------------------------------------------------
// Repositories
// ---------------------------------------------------------------------------

export const repo_read = tool({
  description:
    "GitHub Repository read operations: view or list repositories",
  args: {
    action: tool.schema.enum(["view", "list"]).describe("Repo action"),
    repository: tool.schema
      .string()
      .optional()
      .describe("Repository (owner/repo format, for view)"),
    owner: tool.schema
      .string()
      .optional()
      .describe("Repository owner (for list)"),
    limit: tool.schema
      .string()
      .optional()
      .describe("Max results (for list)"),
  },
  async execute(args) {
    const cmd = ["repo", args.action]
    if (args.action === "view" && args.repository) {
      cmd.push(args.repository)
    } else if (args.action === "list") {
      if (args.owner) cmd.push(args.owner)
      if (args.limit) cmd.push("--limit", args.limit)
    }
    return runGh(cmd)
  },
})

export const repo_write = tool({
  description:
    "GitHub Repository write operations: create, clone, or fork repositories",
  args: {
    action: tool.schema
      .enum(["create", "clone", "fork"])
      .describe("Repo action"),
    repository: tool.schema
      .string()
      .optional()
      .describe("Repository (owner/repo format, for clone/fork)"),
    name: tool.schema
      .string()
      .optional()
      .describe("Repository name (for create)"),
    description: tool.schema
      .string()
      .optional()
      .describe("Repository description (for create)"),
    is_private: tool.schema
      .boolean()
      .optional()
      .describe("Create as private repository (for create)"),
    clone_dir: tool.schema
      .string()
      .optional()
      .describe("Directory to clone into (for clone)"),
  },
  async execute(args) {
    const cmd = ["repo", args.action]
    if (args.action === "create") {
      if (args.name) cmd.push(args.name)
      if (args.description) cmd.push("--description", args.description)
      cmd.push(args.is_private ? "--private" : "--public")
    } else {
      if (args.repository) cmd.push(args.repository)
      if (args.action === "clone" && args.clone_dir) {
        cmd.push(args.clone_dir)
      }
    }
    return runGh(cmd)
  },
})
