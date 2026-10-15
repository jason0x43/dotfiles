# Contract Template

Use this template when generating `contract.md` after reaching ≥95% confidence.

---

# {Project Name} Contract

**Created**: {date}
**Confidence Score**: {score}/100
**Status**: Draft | Approved

## Problem Statement

{1-3 paragraphs describing:
- What pain point exists
- Who experiences it
- Why it matters
- What happens if not solved}

## Goals

{Numbered list of 3-5 specific, measurable goals. Each goal should answer "what does success look like?"}

1. {Goal 1 with measurable outcome}
2. {Goal 2 with measurable outcome}
3. {Goal 3 with measurable outcome}

## Success Criteria

{Bulleted checklist of testable acceptance criteria. These should be verifiable.}

- [ ] {Criterion 1 - specific and testable}
- [ ] {Criterion 2 - specific and testable}
- [ ] {Criterion 3 - specific and testable}
- [ ] {Criterion 4 - specific and testable}

## Scope Boundaries

### In Scope

{Explicit list of what IS included in this project}

- {Feature/capability 1}
- {Feature/capability 2}
- {Feature/capability 3}

### Out of Scope

{Explicit list of what is NOT included, with brief rationale}

- {Excluded item 1} - {why excluded}
- {Excluded item 2} - {why excluded}

### Future Considerations

{Items explicitly deferred to later phases or projects}

- {Deferred item 1}
- {Deferred item 2}

---

*This contract was generated from brain dump input. Review and approve before proceeding to PRD generation.*

---

## Template Usage Notes

When filling this template:

1. **Problem Statement**: Be specific about WHO has the problem and WHAT the impact is. Avoid vague statements like "things are slow" - instead say "API response times exceed 2s for 40% of users, causing 15% cart abandonment."

2. **Goals**: Use measurable language. Instead of "improve performance," say "reduce p95 latency from 2s to 500ms."

3. **Success Criteria**: Write as if you're writing test cases. Each criterion should be pass/fail verifiable.

4. **Scope Boundaries**: When in doubt, list it as out of scope. It's easier to add later than to remove.

5. **Future Considerations**: Don't delete good ideas that are out of scope - park them here for later.
