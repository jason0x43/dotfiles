# Spec Template

Use this template when generating `spec-phase-{n}.md` for each approved PRD.

---

# Implementation Spec: {Project Name} - Phase {N}

**PRD**: ./prd-phase-{N}.md
**Estimated Effort**: {T-shirt size: S/M/L/XL}

## Technical Approach

{High-level description of the implementation strategy. 2-3 paragraphs covering:
- Overall architecture approach
- Key technical decisions and rationale
- Patterns or frameworks to use
- Any spikes or research needed}

## File Changes

### New Files

| File Path | Purpose |
|-----------|---------|
| `{path/to/new/file.ts}` | {Brief description of what this file does} |
| `{path/to/new/file.ts}` | {Brief description of what this file does} |
| `{path/to/new/file.ts}` | {Brief description of what this file does} |

### Modified Files

| File Path | Changes |
|-----------|---------|
| `{path/to/existing/file.ts}` | {What to add/change and why} |
| `{path/to/existing/file.ts}` | {What to add/change and why} |

### Deleted Files

| File Path | Reason |
|-----------|--------|
| `{path/to/old/file.ts}` | {Why this file is being removed} |

## Implementation Details

### {Component/Feature 1}

**Pattern to follow**: `{path/to/similar/implementation.ts}` (if applicable)

**Overview**: {1-2 sentences describing this component}

```typescript
// Key interfaces or types
interface {InterfaceName} {
  {property}: {type};
  {property}: {type};
}

// Key function signatures
function {functionName}({params}): {returnType} {
  // Implementation notes
}
```

**Key decisions**:
- {Decision 1 and rationale}
- {Decision 2 and rationale}

**Implementation steps**:
1. {Step 1}
2. {Step 2}
3. {Step 3}

### {Component/Feature 2}

**Pattern to follow**: `{path/to/similar/implementation.ts}`

**Overview**: {1-2 sentences}

```typescript
// Key code structure
```

**Key decisions**:
- {Decision and rationale}

**Implementation steps**:
1. {Step 1}
2. {Step 2}

### {Component/Feature 3}

{Same structure as above}

## Data Model

{If applicable - database schema changes, state shape, etc.}

### Schema Changes

```sql
-- New tables
CREATE TABLE {table_name} (
  id UUID PRIMARY KEY,
  {column} {type},
  created_at TIMESTAMP DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_{name} ON {table}({column});
```

### State Shape

```typescript
interface {StateName} {
  {property}: {type};
}
```

## API Design

{If applicable - new or modified endpoints}

### New Endpoints

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/api/{resource}` | {What it does} |
| `GET` | `/api/{resource}/:id` | {What it does} |
| `PUT` | `/api/{resource}/:id` | {What it does} |
| `DELETE` | `/api/{resource}/:id` | {What it does} |

### Request/Response Examples

```typescript
// POST /api/{resource}
// Request
{
  "{field}": "{value}"
}

// Response
{
  "id": "uuid",
  "{field}": "{value}"
}
```

## Testing Requirements

### Unit Tests

| Test File | Coverage |
|-----------|----------|
| `{path/to/test.spec.ts}` | {What it tests} |
| `{path/to/test.spec.ts}` | {What it tests} |

**Key test cases**:
- {Test case 1}
- {Test case 2}
- {Edge case 1}
- {Error case 1}

### Integration Tests

| Test File | Coverage |
|-----------|----------|
| `{path/to/integration.spec.ts}` | {What it tests} |

**Key scenarios**:
- {Happy path scenario}
- {Error handling scenario}
- {Edge case scenario}

### Manual Testing

- [ ] {Manual test step 1}
- [ ] {Manual test step 2}
- [ ] {Manual test step 3}

## Error Handling

| Error Scenario | Handling Strategy |
|----------------|-------------------|
| {Scenario 1} | {How to handle - e.g., "Return 400 with validation errors"} |
| {Scenario 2} | {How to handle - e.g., "Retry 3x with exponential backoff"} |
| {Scenario 3} | {How to handle - e.g., "Log error, return 500, alert on-call"} |

## Validation Commands

```bash
# Type checking
{pnpm run typecheck | npm run typecheck | etc.}

# Linting
{pnpm run lint | npm run lint | etc.}

# Unit tests
{pnpm run test | npm run test | etc.}

# Integration tests
{pnpm run test:integration | etc.}

# Build
{pnpm run build | npm run build | etc.}
```

## Rollout Considerations

{Any feature flags, phased rollout, monitoring, or alerting needed}

- **Feature flag**: {flag name if applicable}
- **Monitoring**: {what metrics to watch}
- **Alerting**: {what alerts to set up}
- **Rollback plan**: {how to rollback if needed}

## Open Items

{Any remaining questions or decisions to make during implementation. Remove if none.}

- [ ] {Open item 1}
- [ ] {Open item 2}

---

*This spec is ready for implementation. Follow the patterns and validate at each step.*

---

## Template Usage Notes

When filling this template:

1. **Technical Approach**: Start with the big picture. Don't dive into code yet.

2. **File Changes**: Be exhaustive. Missing a file here means surprise work later.

3. **Implementation Details**:
   - Reference existing code patterns when possible ("follow the pattern in X")
   - Include actual code snippets for complex logic
   - Number the implementation steps

4. **Data Model**: Include schema AND indexes. Don't forget migrations.

5. **API Design**: Include examples. They catch misunderstandings early.

6. **Testing**: Don't just list files. Describe KEY test cases, especially edge cases.

7. **Error Handling**: Be explicit. "Handle errors" is not a strategy.

8. **Validation Commands**: Copy-paste ready. No one should guess how to run tests.

9. **Rollout**: Even if it's "just deploy," say so. Feature flags aren't always needed.
