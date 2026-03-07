# Agentic Development Patterns
## Lessons Learned & Reusable Strategies

**Purpose:** Capture patterns from this project that can be extracted into reusable skills/processes for future lights-out factory-style development.

---

## 1. Council of LLMs Pattern

### What It Is
A simulated review board with distinct personas that evaluate work from different perspectives. Forces multi-angle thinking and catches blind spots.

### The Personas That Worked
| Persona | Focus | Value |
|---------|-------|-------|
| **Product Lead** | User value, simplicity, not over-engineering | Catches scope creep, questions necessity |
| **Systems Engineer** | Architecture, edge cases, data consistency | Catches technical debt, data flow issues |
| **Front-End Architect** | UI patterns, maintainability, design systems | Catches UI/UX gaps, missing specifications |
| **Agentic Engineer** | Automation, testability, CI/CD, agent-friendliness | Catches automation gaps, ensures machine-readability |

### When to Invoke Council
- **Pre-implementation**: Before starting major work (caught XcodeGen over-engineering)
- **Post-phase**: After completing a phase, before proceeding
- **Pre-submission**: Final quality gate before delivery
- **When stuck**: Fresh perspectives can unblock

### Pattern for Invoking
```
1. Summarize current state (what exists, what's decided)
2. Each persona reviews from their lens
3. Collect concerns and recommendations
4. Synthesize into: Blocking / High Priority / Medium / Accepted
5. Make decisions and document in COUNCIL_LOG.md
6. Update plan based on decisions
```

### Key Insight
The council caught that XcodeGen was over-engineering for a single-target app. A single perspective (mine) might have proceeded with unnecessary complexity. **Multiple perspectives reduce over-engineering.**

---

## 2. Documentation-First Development

### What It Is
Write PRD → Technical Design → Specs (YAML) → Then code. Documentation becomes the source of truth that agents can reference.

### Why It Works for Agentic Development
- Agents can read docs to understand context without re-exploring
- YAML specs are machine-parseable (agents can load cat/plant definitions)
- Reduces context window usage (point to doc instead of explaining)
- Creates audit trail of decisions

### Key Documents
| Document | Purpose | When Updated |
|----------|---------|--------------|
| `PRD.md` | What we're building and why | Major feature changes |
| `TechnicalDesign.md` | How we're building it | Architecture changes |
| `Specs/*.yaml` | Machine-readable content definitions | Content changes |
| `AGENTIC_PLAN.md` | How agents should work | Process changes |
| `COUNCIL_LOG.md` | Decision history | After each review |
| `BUILD_LOG.md` | Execution history | After each phase |

### Key Insight
**Specs as YAML** (cats.yaml, plants.yaml, tasks.yaml) separates content from code. An agent can modify a cat's unlock requirement without touching Swift code. This is crucial for factory-style work.

---

## 3. Phase-Based Execution with Quality Gates

### What It Is
Break work into discrete phases. Each phase has clear tasks and a quality gate that must pass before proceeding.

### Structure
```
Phase 0: Environment Verification
  Quality Gate: All tools available

Phase 1: Project Setup
  Quality Gate: Project compiles

Phase 2: Core Implementation
  Quality Gate: Unit tests pass

Phase 3: UI Implementation
  Quality Gate: App launches, UI visible via idb

Phase 4: Integration
  Quality Gate: Full flow works

Phase 5: Submission Prep
  Quality Gate: fastlane dry-run succeeds
```

### Why It Works
- Clear stopping points for review
- Easy to resume if interrupted
- Git commits between phases enable rollback
- Quality gates prevent cascading failures

### Key Insight
**Phase 0 (Environment Verification) is critical.** We discovered fastlane wasn't installed and Ruby was too old BEFORE wasting cycles on code that couldn't deploy. Always verify tools first.

---

## 4. Sub-Agent Delegation Pattern

### When to Spawn Sub-Agent
- Task is self-contained (clear inputs/outputs)
- Task touches > 3 files
- Task is complex enough to benefit from focused context
- Tasks are independent and can run in parallel

### When to Stay in Main Context
- Orchestration and decision-making
- Council reviews
- Cross-cutting concerns
- Simple single-file edits

### Sub-Agent Prompt Structure
```
Task: [Clear one-line description]

Context:
- Working directory: [path]
- Relevant specs: [file references]

Requirements:
- [Specific requirement 1]
- [Specific requirement 2]

Acceptance Criteria:
- [Verifiable outcome 1]
- [Verifiable outcome 2]

Verification Command:
- [Command to verify success]

Return:
- [What to report back]
```

### Key Insight
The project creation sub-agent worked well because it had:
1. Clear scope (create Xcode project)
2. Specific requirements (bundle ID, iOS version, etc.)
3. Verification command (xcodebuild)
4. Clear success criteria (build succeeds)

---

## 5. Error Recovery Patterns

### Build Failures
```
1. Read full error output
2. Identify root cause (syntax, import, config)
3. Fix in source
4. Rebuild
5. If still failing, check recent changes
```

### Environment Issues
```
1. Check if tool exists: which [tool]
2. Check version: [tool] --version
3. Try alternative install method (brew vs gem vs pip)
4. Document workaround for future
```

### Permission Issues
```
1. Try user-local install first (--user-install, --user)
2. If fails, try Homebrew
3. Avoid sudo unless absolutely necessary
4. Document the working approach
```

### Key Insight
When `gem install fastlane` failed due to old Ruby, switching to `brew install fastlane` worked immediately. **Have fallback installation methods ready.**

---

## 6. Simulator Verification Without Screenshots

### Why No Screenshots
- Expensive (tokens)
- Slow (render + encode + transmit)
- Unreliable for AI parsing
- User's CLAUDE.md explicitly prohibits them

### Use idb Instead
```bash
# Get UI tree (this is your "eyes")
idb ui describe-all --udid $UDID

# Find specific elements
idb ui describe-all --udid $UDID | grep -i "button"

# Interact
idb ui tap X Y --udid $UDID
```

### Fallback to simctl
```bash
# Basic launch verification
xcrun simctl launch booted com.bundle.id

# Check if app is running
xcrun simctl listapps booted | grep bundle.id
```

### Key Insight
The accessibility tree from `idb ui describe-all` provides structured, parseable data about UI state. This is far more reliable than trying to interpret screenshots.

### Observed Issue (March 7, 2026)
idb failed with companion connection issues. Fallback to simctl worked:
```bash
# Verify app installed
xcrun simctl listapps booted | grep "bundle.id"

# Get app container
xcrun simctl get_app_container booted com.bundle.id
```
**Lesson:** Always have simctl as fallback when idb fails.

---

## 7. Context Management Strategies

### Keep Context Clean
- Summarize findings to docs rather than keeping in conversation
- Reference docs instead of re-reading files
- Use sub-agents for isolated tasks
- Commit and log progress frequently

### When Context Gets Heavy
1. Write summary to a doc file
2. Update BUILD_LOG.md with current state
3. Commit changes
4. Sub-agent can continue with fresh context + docs

### Documentation as Context Transfer
Instead of: "Remember, we decided to use SF Symbols for placeholders"
Do: Write to COUNCIL_LOG.md, then any agent can read it

### Key Insight
**Docs are persistent context.** Conversation context is ephemeral and expensive. Move decisions to docs early and often.

---

## 8. Decision Logging Pattern

### Every Significant Decision Should Be Logged
```markdown
## Decision: [Title]
**Date:** [Date]
**Context:** [Why this came up]
**Options Considered:**
1. [Option A] - [Pros/Cons]
2. [Option B] - [Pros/Cons]
**Decision:** [What we chose]
**Rationale:** [Why]
```

### Where to Log
- Architecture decisions → COUNCIL_LOG.md
- Process decisions → AGENTIC_PLAN.md
- Build/deploy decisions → BUILD_LOG.md

### Key Insight
Logged decisions can be referenced later. "Why did we skip XcodeGen?" → Check COUNCIL_LOG.md Review #1.

---

## 9. Task Manifest Pattern (tasks.yaml)

### Structure
```yaml
tasks:
  - id: TASK-001
    name: Human-readable name
    feature: feature-area
    status: pending | in_progress | completed
    depends_on: [TASK-000]
    files: [list of files to create/modify]
    acceptance:
      - Verifiable criterion 1
      - Verifiable criterion 2
```

### Benefits
- Agents can read and update status
- Dependencies are explicit
- File mapping helps agents find relevant code
- Acceptance criteria enable verification

### Key Insight
**Tasks should be agent-parseable, not just human-readable.** YAML with acceptance criteria lets an agent know when a task is truly done.

---

## 10. Git Commit Cadence

### Commit After Each Phase
```bash
git add . && git commit -m "feat(phase-N): description"
```

### Why
- Enables rollback if next phase fails
- Creates audit trail
- Makes it easy to resume after interruption
- Helps track what changed when

### Commit Message Format
```
type(scope): description

Types: feat, fix, docs, refactor, test, chore
Scope: phase-N, feature-name, or component
```

---

## Patterns to Extract as Skills

The following patterns could become reusable Claude Code skills:

1. **`/council-review`** - Invoke Council of LLMs on current work
2. **`/phase-gate`** - Check quality gate for current phase
3. **`/env-check`** - Verify development environment
4. **`/build-log`** - Update BUILD_LOG.md with current status
5. **`/decision`** - Log a decision with context and rationale

---

## 11. Xcode Project File Management

### The Problem
Sub-agents may create Swift files but not update the `.xcodeproj/project.pbxproj` file. SourceKit will show "Cannot find type" errors even though files exist on disk.

### Detection
- SourceKit errors about missing types
- Files exist in filesystem but `grep` on project.pbxproj shows no matches

### Solution
After any sub-agent creates new Swift files, verify and update project.pbxproj:
1. Check files are in project: `grep "FileName.swift" project.pbxproj`
2. If missing, update project.pbxproj with:
   - PBXFileReference for each new file
   - PBXBuildFile for each source file
   - PBXGroup entries for new directories
   - Add files to PBXSourcesBuildPhase

### Key Insight
**Always verify sub-agent output includes project file updates.** Include explicit instruction in prompts: "Update project.pbxproj to include new files."

---

## Anti-Patterns Observed

### Over-Engineering Early
- XcodeGen for single-target app (caught by Council)
- Complex abstractions before simple code works

### Skipping Environment Verification
- Would have wasted time if fastlane wasn't working

### Not Documenting Decisions
- Future agents/humans won't know why choices were made

### Monolithic Sub-Agent Tasks
- Better: Small, focused tasks with clear acceptance criteria
- Worse: "Build the whole app" as one task

---

*This document will be updated as more patterns emerge during development.*
