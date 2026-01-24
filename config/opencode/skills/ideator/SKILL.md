---
name: ideation
description: Transform raw brain dumps (dictated freestyle) into structured implementation artifacts. Use when user has messy ideas, scattered thoughts, or dictated stream-of-consciousness about something they want to build. Produces contracts, phased PRDs, and implementation specs written to ./docs/ideation/{project-name}/.
metadata:
    source: https://github.com/nicknisi/claude-plugins/tree/main/plugins/ideation
---

# Ideation

Transform unstructured brain dumps into structured, actionable implementation artifacts through a confidence-gated workflow.

## Critical: Use AskUserQuestion Tool

**ALWAYS use the `AskUserQuestion` tool when asking clarifying questions.** Do not ask questions in plain text. The tool provides structured options and ensures the user can respond clearly.

Use `AskUserQuestion` for:
- Clarifying questions during confidence scoring (Phase 2)
- Project name confirmation before writing artifacts
- Contract approval before PRD generation
- PRD review feedback before spec generation
- Any decision point requiring user input

## Workflow Pipeline

```
INTAKE → CONTRACT FORMATION → PRD GENERATION → SPEC GENERATION → EXECUTION HANDOFF
              ↓                                                        ↓
         confidence < 95%?                                     [Fresh Session]
              ↓                                                        ↓
         ASK QUESTIONS                                         /execute-spec
              ↓                                                        ↓
         (loop until ≥95%)                                    Review → Test → Commit
```

## Phase 1: Intake

Accept whatever the user provides:

- Scattered thoughts and half-formed ideas
- Voice dictation transcripts (messy, stream-of-consciousness)
- Bullet points mixed with rambling
- Topic jumping and tangents
- Contradictions and unclear statements
- Technical jargon mixed with vague descriptions

**Don't require organization. The mess is the input.**

Acknowledge receipt and begin analysis. Do not ask for clarification yet.

## Phase 2: Contract Formation

### 2.1 Analyze the Brain Dump

Extract from the raw input:

1. **Problem signals**: What pain point or need is being described?
2. **Goal signals**: What does the user want to achieve?
3. **Success signals**: How will they know it worked?
4. **Scope signals**: What's included? What's explicitly excluded?
5. **Contradictions**: Note any conflicting statements

### 2.2 Calculate Confidence Score

Load `references/confidence-rubric.md` for detailed scoring criteria.

Score each dimension (0-20 points):

| Dimension | Question |
|-----------|----------|
| Problem Clarity | Do I understand what problem we're solving and why it matters? |
| Goal Definition | Are the goals specific and measurable? |
| Success Criteria | Can I write tests or validation steps for "done"? |
| Scope Boundaries | Do I know what's in and out of scope? |
| Consistency | Are there contradictions I need resolved? |

**Total: /100 points**

### 2.3 Confidence Thresholds

| Score | Action |
|-------|--------|
| < 70 | Major gaps. Ask 5+ questions targeting lowest dimensions. |
| 70-84 | Moderate gaps. Ask 3-5 targeted questions. |
| 85-94 | Minor gaps. Ask 1-2 specific questions. |
| ≥ 95 | Ready to generate contract. |

### 2.4 Ask Clarifying Questions

When confidence < 95%, **MUST use `AskUserQuestion` tool** to ask clarifying questions. Structure questions with clear options when possible.

**Using AskUserQuestion effectively**:
- Provide 2-4 options per question when choices are clear
- Use `multiSelect: true` when multiple answers apply
- Keep question headers short (max 12 chars)
- Include descriptions that explain implications of each choice

**Question strategy**:

- Target the lowest-scoring dimension first
- Be specific, not open-ended
- Offer options when possible ("Is it A, B, or C?")
- Reference what was stated ("You mentioned X, did you mean...?")
- Limit to 3-5 questions per round
- After each round, recalculate confidence

**Question templates by dimension**:

**Problem Clarity**:
- "What specific problem are you trying to solve?"
- "Who experiences this problem and how often?"
- "What's the cost of NOT solving this?"

**Goal Definition**:
- "What does success look like for this project?"
- "How will you measure whether this worked?"
- "What specific metrics should improve?"

**Success Criteria**:
- "How will you know when you're done?"
- "What tests would prove this feature works?"
- "What would a QA person check?"

**Scope Boundaries**:
- "What is explicitly NOT part of this project?"
- "Are there related features we should defer?"
- "What's the MVP vs. nice-to-have?"

**Consistency**:
- "You mentioned [X] but also [Y]. Which takes priority?"
- "These requirements seem to conflict. Can you clarify?"
- "How should we handle [edge case]?"

### 2.5 Generate Contract

When confidence ≥ 95%, generate the contract document.

1. Use `AskUserQuestion` to confirm project name if not obvious from context
2. Convert to kebab-case for directory name
3. Create output directory: `./docs/ideation/{project-name}/`
4. Write `contract.md` using `references/contract-template.md`
5. Use `AskUserQuestion` to get approval: "Does this contract accurately capture your intent?"

**Do not proceed to PRD generation until contract is explicitly approved.**

## Phase 3: PRD Generation

After contract is approved:

### 3.1 Determine Phases

Analyze the contract and break scope into logical implementation phases.

**Phasing criteria**:
- Dependencies (what must be built first?)
- Risk (tackle high-risk items early)
- Value delivery (can users benefit after each phase?)
- Complexity (balance phases for consistent effort)

Typical phasing:
- Phase 1: Core functionality / MVP
- Phase 2: Enhanced features
- Phase 3: Polish and optimization
- Phase N: Future considerations

### 3.2 Generate PRDs

For each phase, generate `prd-phase-{n}.md` using `references/prd-template.md`.

Include:
- Phase overview and rationale
- User stories for this phase
- Functional requirements (grouped)
- Non-functional requirements
- Dependencies (prerequisites and outputs)
- Acceptance criteria

### 3.3 Present for Review

Show all PRDs to user. Use `AskUserQuestion` to gather feedback:

```
Question: "Do these PRD phases look correct?"
Options:
- "Approved" - Phases and requirements look good, proceed to specs
- "Adjust phases" - Need to move features between phases
- "Missing requirements" - Some requirements are missing or unclear
- "Start over" - Need to revisit the contract
```

Iterate until user explicitly approves.

## Phase 4: Spec Generation

After PRDs are approved:

### 4.1 Generate Implementation Specs

For each approved phase, generate `spec-phase-{n}.md` using `references/spec-template.md`.

Include:
- Technical approach
- File changes (new and modified)
- Implementation details with code patterns
- Testing requirements
- Error handling
- Validation commands

### 4.2 Final Review

Present specs to user. Proceed to execution handoff.

## Phase 5: Execution Handoff

After specs are generated, summarize and hand off for implementation.

### 5.1 Present Handoff Summary

```
Ideation complete. Artifacts written to `./docs/ideation/{project-name}/`.

**To implement:**
1. Start a fresh Claude session (clears context)
2. Run: /execute-spec docs/ideation/{project-name}/spec-phase-1.md
3. Review changes, run tests, commit
4. Repeat for each phase
```

### 5.2 Why Fresh Sessions?

- Ideation consumes significant context (contract, PRDs, specs)
- Execution benefits from clean context focused on the spec
- Human review between phases catches issues early
- Each phase is independently committable

## Output Artifacts

All artifacts written to `./docs/ideation/{project-name}/`:

```
contract.md              # Lean contract (problem, goals, success, scope)
prd-phase-1.md           # Phase 1 requirements
prd-phase-2.md           # Phase 2 requirements (if applicable)
...
spec-phase-1.md          # Phase 1 implementation spec
spec-phase-2.md          # Phase 2 implementation spec
...
```

## Bundled Resources

### References

- `references/contract-template.md` - Template for lean contract document
- `references/prd-template.md` - Template for phased PRD documents
- `references/spec-template.md` - Template for implementation specs
- `references/confidence-rubric.md` - Detailed scoring criteria for confidence assessment

## Workflow Example

**User provides brain dump** (via dictation):

```
okay so i'm thinking about this feature where users can like save their
favorite items you know like bookmarking but also they should be able to
organize them into folders or something maybe tags actually tags might be
better because folders are too rigid and oh we should probably have a
search too because if they have a lot of bookmarks it'll be hard to find
anything and maybe some kind of sharing eventually but that's probably
phase 2 or something and it should work offline too because people might
be on planes or whatever and sync when they come back online
```

**Process**:

1. **Intake**: Accept without judgment

2. **Analysis**:
   - Problem: Users need to save and organize content
   - Goals: Save items, organize with tags, search, offline support
   - Unclear: What items? Why tags > folders? Sharing scope? Offline priority?
   - Confidence: ~55/100 (low problem clarity, unclear scope)

3. **Questions** (round 1):
   - "What type of items are users bookmarking? Articles, products, posts?"
   - "You mentioned tags over folders. Should tags be user-created or predefined?"
   - "Is offline support MVP or can it wait for phase 2?"
   - "When you say 'sharing eventually,' what does that look like?"

4. **User responds** → Recalculate confidence → Repeat if needed

5. **Confidence reaches 96%** → Generate contract

6. **Contract approved** → Generate PRDs:
   - Phase 1: Core bookmarking with tags
   - Phase 2: Search and filtering
   - Phase 3: Offline support
   - Phase 4: Sharing (future)

7. **PRDs approved** → Generate specs for each phase

8. **Execution handoff**: Summarize artifacts and next steps for fresh-session execution

9. **Implementation** (fresh sessions): For each phase:
   - Start fresh Claude session
   - Run `/execute-spec spec-phase-{n}.md`
   - Review, test, commit
   - Repeat for next phase

## Important Notes

- **ALWAYS use `AskUserQuestion` tool for clarifications and approvals.** Never ask questions in plain text.
- Never skip the confidence check. Don't assume understanding.
- Always write artifacts to files. Don't just display them.
- Each phase should be independently valuable.
- Specs should be detailed enough to implement without re-reading PRDs.
- Keep contracts lean. Heavy docs slow iteration.
