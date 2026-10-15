# Confidence Assessment Rubric

Use this rubric to score brain dump clarity before generating a contract.

**Threshold**: 95 points minimum to proceed to contract generation.

## Scoring Dimensions

### 1. Problem Clarity (0-20 points)

| Score | Criteria |
|-------|----------|
| 0-5 | Problem not stated or completely unclear. No idea what we're solving. |
| 6-10 | Problem mentioned but vague ("things are slow", "users complain", "it's broken"). |
| 11-15 | Problem clear but missing context: who experiences it, how often, or what impact. |
| 16-20 | Problem crystal clear: who experiences it, what happens, when it occurs, impact quantified. |

**Questions to ask if low**:
- "What specific problem are you trying to solve?"
- "Who experiences this problem? How often?"
- "What's the cost of not solving this? (time, money, frustration)"
- "Can you describe a specific incident where this was a problem?"

**Examples**:
- Score 5: "The app is bad"
- Score 10: "Users say the app is slow"
- Score 15: "The checkout page loads slowly, causing cart abandonment"
- Score 20: "Checkout page p95 latency is 3.2s, causing 18% cart abandonment for returning customers, costing ~$50k/month in lost revenue"

---

### 2. Goal Definition (0-20 points)

| Score | Criteria |
|-------|----------|
| 0-5 | No goals stated. Just a problem or complaint. |
| 6-10 | Vague aspirations ("make it better", "improve UX", "users should like it more"). |
| 11-15 | Goals stated but unmeasurable ("users should be happier", "it should feel fast"). |
| 16-20 | SMART goals with specific metrics ("reduce checkout latency to under 500ms p95"). |

**Questions to ask if low**:
- "What does success look like for this project?"
- "How will you measure whether this worked?"
- "What specific number or metric should change? By how much?"
- "If this project succeeds, what will be different in 3 months?"

**Examples**:
- Score 5: (none stated)
- Score 10: "Make checkout better"
- Score 15: "Users should complete checkout faster"
- Score 20: "Reduce checkout p95 latency from 3.2s to 500ms, increasing conversion rate by 10%"

---

### 3. Success Criteria (0-20 points)

| Score | Criteria |
|-------|----------|
| 0-5 | None provided. No way to know when we're done. |
| 6-10 | Subjective criteria only ("looks good", "feels fast", "stakeholder likes it"). |
| 11-15 | Some measurable criteria but incomplete coverage of goals. |
| 16-20 | Clear, testable acceptance criteria for ALL stated goals. Pass/fail verifiable. |

**Questions to ask if low**:
- "How will you know when this is done?"
- "What tests would prove this feature works correctly?"
- "What would a QA person check before signing off?"
- "What would you demo to stakeholders to prove success?"

**Examples**:
- Score 5: (none stated)
- Score 10: "It should work well"
- Score 15: "Page loads in under 1 second" (good but incomplete)
- Score 20: "Checkout page loads in <500ms p95, all payment methods work, order confirmation email sends within 30s, no 500 errors for 24 hours post-deploy"

---

### 4. Scope Boundaries (0-20 points)

| Score | Criteria |
|-------|----------|
| 0-5 | Unlimited scope. No boundaries stated. Everything could be in scope. |
| 6-10 | Some boundaries implied but not explicit. "We're not redesigning everything" type statements. |
| 11-15 | Boundaries stated but gaps exist. Some adjacent features unclear. |
| 16-20 | Clear in/out of scope with rationale for exclusions. Future considerations noted. |

**Questions to ask if low**:
- "What is explicitly NOT part of this project?"
- "Are there related features we should defer to later?"
- "What's the MVP vs. nice-to-have?"
- "If you had to ship in half the time, what would you cut?"
- "What adjacent features should we explicitly exclude?"

**Examples**:
- Score 5: "Fix the checkout" (could mean anything)
- Score 10: "Fix checkout performance, nothing else" (vague)
- Score 15: "Optimize checkout page load, but not payment processing" (better but gaps)
- Score 20: "In scope: checkout page load optimization, image lazy loading, API caching. Out of scope: payment gateway changes (vendor decision), mobile app (separate team), analytics dashboard (phase 2). Future: A/B testing different layouts after baseline established."

---

### 5. Consistency (0-20 points)

| Score | Criteria |
|-------|----------|
| 0-5 | Major contradictions in requirements. Impossible to satisfy both. |
| 6-10 | Some conflicting statements that need resolution. |
| 11-15 | Minor inconsistencies that need clarification but aren't blockers. |
| 16-20 | Internally consistent throughout. No contradictions. |

**Questions to ask if low**:
- "You mentioned [X] but also [Y]. These seem to conflict. Which takes priority?"
- "Earlier you said [A], but now [B]. Can you clarify?"
- "How should we handle [edge case where requirements conflict]?"
- "If we can only do one of [X] or [Y], which matters more?"

**Examples**:
- Score 5: "Must be real-time" + "Must work offline" + "No local storage" (impossible)
- Score 10: "Keep it simple" + "Add these 15 features" (tension)
- Score 15: "Fast load times" + "Show all products on page load" (minor tension, resolvable)
- Score 20: All requirements align. Priorities clear when tradeoffs exist.

---

## Confidence Thresholds

| Total Score | Interpretation | Action |
|-------------|----------------|--------|
| < 70 | Major gaps in understanding | Ask 5+ questions targeting lowest-scoring dimensions. May need multiple rounds. |
| 70-84 | Moderate gaps | Ask 3-5 targeted questions. One more round likely sufficient. |
| 85-94 | Minor gaps | Ask 1-2 specific questions. Almost ready. |
| ≥ 95 | Ready | Generate contract. Proceed to PRD generation. |

---

## Question Best Practices

When asking clarifying questions:

### Do:
- **Be specific**: "What happens when a user tries to bookmark while offline?" not "Tell me more about offline."
- **Offer options**: "Is offline support A) critical for MVP, B) nice-to-have phase 1, or C) future consideration?"
- **Reference context**: "You mentioned 'tags are better than folders.' Should tags be user-created, predefined, or both?"
- **Limit quantity**: 3-5 questions max per round. Don't overwhelm.
- **Prioritize**: Target the lowest-scoring dimension first.
- **Chain logically**: Questions should build understanding, not jump around.

### Don't:
- Ask open-ended questions: "Tell me more" is not useful.
- Ask redundant questions: If they said "mobile app," don't ask "will this be on mobile?"
- Ask leading questions: "You don't want offline mode, right?" biases the answer.
- Ask compound questions: "What's the scope and timeline and who's the user?" is three questions.
- Skip context: Don't ask about something without referencing what they said.

---

## Scoring Worksheet

Use this to track your assessment:

| Dimension | Score | Notes |
|-----------|-------|-------|
| Problem Clarity | /20 | |
| Goal Definition | /20 | |
| Success Criteria | /20 | |
| Scope Boundaries | /20 | |
| Consistency | /20 | |
| **TOTAL** | **/100** | |

**Lowest dimension**: _________________ (target questions here first)

**Questions to ask**:
1.
2.
3.

---

## Recalculation

After each round of questions:

1. Re-read the original brain dump + new answers
2. Re-score all 5 dimensions
3. If still < 95, identify new lowest dimension
4. Ask targeted questions
5. Repeat until ≥ 95

**Typical progression**:
- Round 1: 50-65 → 70-80
- Round 2: 70-80 → 85-92
- Round 3: 85-92 → 95+

If not progressing after 3 rounds, consider:
- User may not have clear requirements yet (suggest they think more)
- Scope may be too large (suggest breaking into smaller projects)
- Problem may be poorly defined at org level (suggest stakeholder alignment first)
