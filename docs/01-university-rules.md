# University internship rules

**Owner: Suja — Trello card X01. This is the first thing the team needs, because
`Common/GradingPolicy.cs`, the evaluation forms and the completion review all
read their numbers from here.**

The requirements document is explicit on two points:

1. Use the **real** university assigned to Group 4 — its name, logo, colours,
   colleges and majors.
2. Where the university does not publish a rule, the team may adopt a
   reasonable method, **but the document must say in so many words that it is
   hypothetical.** Leaving that undisclosed is a direct violation of the brief.

Fill in every section. Where the answer is assumed rather than sourced, write
"**hypothetical**" next to it and say why the official figure was unavailable.

---

## 1. University and college

| Field | Value | Source |
| --- | --- | --- |
| University name (English) | | |
| University name (Arabic) | | |
| College | | |
| Majors offered | | |
| Official website | | |
| Brand colours (hex) | | |
| Logo file | `Assets/images/logo.png` | |

Once the colours are known, set them in `Assets/css/site.css` under `:root`
and in `Common/Constants.cs`.

## 2. Internship requirements

| Field | Value | Source / hypothetical |
| --- | --- | --- |
| Required training hours | | |
| Duration in weeks | | |
| Minimum hours per week | | |
| Which academic year students may train | | |
| Prerequisites (credit hours passed, GPA, …) | | |

Put the hours figure into `Constants.DefaultRequiredHours`.

## 3. How training hours get approved

The requirements document is specific: *"Training hours are not approved
automatically simply because a task has been completed."* Describe the actual
process.

- Who reports hours?
- Who approves them — the company supervisor, the academic supervisor, or both?
- Is there a timesheet, a weekly report, or per-task reporting?
- What happens to rejected hours?

This section drives `Services/HoursService.cs` and card S04.

## 4. Evaluation method and weights

List every component that contributes to the final result, with its own scale —
**not** a flat 100 for everything, which the brief forbids.

| Component | Who evaluates | Max score | Weight % | Source / hypothetical |
| --- | --- | --- | --- | --- |
| Graded tasks | Company supervisor | | | |
| Company final evaluation | Company supervisor | | | |
| Academic final evaluation | Academic supervisor | | | |
| *(add rows as the university defines them)* | | | | |

Weights must total 100. `Common/GradingPolicy.WeightsAreValid()` checks this at
run time and `GradingService` throws if it fails, so a wrong figure here fails
loudly instead of producing silently wrong grades.

### Company final evaluation criteria

| Criterion | Max score | Weight % |
| --- | --- | --- |
| | | |

### Academic final evaluation criteria

| Criterion | Max score | Weight % |
| --- | --- | --- |
| | | |

## 5. Grade bands

| Letter | From % | To % |
| --- | --- | --- |
| | | |

Pass mark: ____ %. Put these into `GradingPolicy.ToLetter` and
`GradingPolicy.PassMarkPercent`.

## 6. Completion conditions

What must be true before the coordinator may approve completion? For example:
approved hours at or above the requirement, both final evaluations submitted,
final result at or above the pass mark, no outstanding revision requests.

List them explicitly — card A12 turns this list into the approval gate, and the
live demo walks through it.

## 7. Worked example

Invent one student, fill in every score, and compute the final result by hand.

Card A11 is accepted only when the system reproduces this number exactly, so
this section is the test case for the whole grading implementation.
