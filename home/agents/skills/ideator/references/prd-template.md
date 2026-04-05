# PRD Template

Use this template when generating `prd-phase-{n}.md` for each implementation phase.

---

# PRD: {Project Name} - Phase {N}

**Contract**: ./contract.md
**Phase**: {N} of {total phases}
**Focus**: {One-line description of this phase's focus}

## Phase Overview

{2-3 paragraphs describing:
- What this phase accomplishes
- Why it's sequenced at this position
- What value users get after this phase completes
- Key dependencies or constraints}

## User Stories

{Numbered user stories for this phase. Format: As a [user type], I want [capability] so that [benefit]}

1. As a {user type}, I want {capability} so that {benefit}
2. As a {user type}, I want {capability} so that {benefit}
3. As a {user type}, I want {capability} so that {benefit}

## Functional Requirements

### {Feature Group 1}

- **FR-{N}.1**: {Requirement description}
- **FR-{N}.2**: {Requirement description}
- **FR-{N}.3**: {Requirement description}

### {Feature Group 2}

- **FR-{N}.4**: {Requirement description}
- **FR-{N}.5**: {Requirement description}

### {Feature Group 3}

- **FR-{N}.6**: {Requirement description}

## Non-Functional Requirements

- **NFR-{N}.1**: {Performance requirement - e.g., "API responses under 200ms p95"}
- **NFR-{N}.2**: {Security requirement - e.g., "All user data encrypted at rest"}
- **NFR-{N}.3**: {Accessibility requirement - e.g., "WCAG 2.1 AA compliant"}
- **NFR-{N}.4**: {Scalability requirement - e.g., "Support 10k concurrent users"}

## Dependencies

### Prerequisites

{What must be complete before this phase can start}

- {Prerequisite 1 - e.g., "Phase 1 complete"}
- {Prerequisite 2 - e.g., "Database schema deployed"}
- {Prerequisite 3 - e.g., "Auth service available"}

### Outputs for Next Phase

{What this phase produces that subsequent phases need}

- {Output 1 - e.g., "User model with authentication"}
- {Output 2 - e.g., "Base API structure"}

## Acceptance Criteria

{Testable criteria that prove this phase is complete}

- [ ] {Criterion 1 - specific and verifiable}
- [ ] {Criterion 2 - specific and verifiable}
- [ ] {Criterion 3 - specific and verifiable}
- [ ] {Criterion 4 - specific and verifiable}
- [ ] All unit tests passing
- [ ] Integration tests passing
- [ ] No critical bugs open

## Open Questions

{Unresolved items that need answers during implementation. Remove section if none.}

- {Question 1}
- {Question 2}

---

*Review this PRD and provide feedback before spec generation.*

---

## Template Usage Notes

When filling this template:

1. **Phase Overview**: Explain WHY this phase exists and what's special about it. Don't just list features.

2. **User Stories**: Keep them focused on user value, not implementation details. "As a user, I want to log in" not "As a user, I want a JWT token."

3. **Functional Requirements**:
   - Use unique IDs (FR-1.1, FR-1.2) for traceability
   - Group by feature area
   - Be specific enough to implement but not so detailed you're writing specs

4. **Non-Functional Requirements**: Don't skip these. Performance, security, and accessibility requirements are critical.

5. **Dependencies**: Be explicit about what must exist before starting and what you're producing for others.

6. **Acceptance Criteria**: Write these as if QA will use them for testing. Pass/fail only.

7. **Open Questions**: Don't hide uncertainty. Surface it here so it gets addressed.
