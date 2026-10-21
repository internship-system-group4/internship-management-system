# X06: integration and live demo checklist

Owner: Osama. Local tests are implemented for application submission/review,
offer confirmation, shared layouts and coordinator monitoring. X06 is **not complete**
until the real Firebase environment and the other owners' pages pass the full flow.
Local simulation results are not evidence of live Firebase permissions or indexes.

## Before the demo

- [ ] Record the Git commit being demonstrated and build the solution successfully.
- [ ] Confirm teammates' pages are implemented and integrated, not placeholders.
- [ ] Configure the team's ignored `App_Secrets.config` privately; never commit it.
- [ ] Use dedicated demo accounts for all four roles with correct Auth UIDs,
      `users/{uid}/Id`, role, active status and supervisor/company relationships.
- [ ] Have Ahmad review the database rules and merge indexes from
      `05-firebase-setup.md` and `10-coordinator-monitoring.md`.
- [ ] Create a demo opportunity through the owning workflow with eligibility,
      available seats and an unexpired deadline. Preserve existing team data;
      do not reimport the seed at the root.
- [ ] Prepare demo CV/submission HTTPS links and known task/evaluation mark scales.
- [ ] Agree the university-required hours, grade weights and completion conditions
      with Suja/Ahmad. Do not infer policy from fixture examples.

## Full live flow and expected evidence

| Step | Owner dependency | Expected result | Live result |
| --- | --- | --- | --- |
| Login, first-password change and account guards | Ahmad | Correct role dashboard; inactive/wrong role blocked | Pending |
| Explore and select an eligible opportunity | Sara Rajoub | Correct company, eligibility, deadline and seats | Pending |
| Apply, including invalid/duplicate cases | Osama O01 | One Pending record; validation writes nothing | Pending |
| Student My Applications and company review | Osama O02/O04 | Same application appears in both authorized views | Pending |
| Company accepts/rejects with reason | Osama O05 | Student sees the persisted decision; other company blocked | Pending |
| Student confirms an accepted offer | Osama O03 | One `placements/{studentUid}`; concurrent confirmation cannot overwrite it | Pending |
| Assign and submit a task, then request revision/resubmit | Fatima | Linked task/submission attempts and feedback persist | Pending |
| Review tasks and approve/reject reported hours | Fatima / owning hours workflow | Actual marks retained; only approved hours count | Pending |
| Monitor placements and student progress | Osama O06–O08 | Fresh counts, filters and details agree with database records | Pending |
| Submit company final evaluation | Nada | Correct scale and confidential record | Pending |
| Academic follow-up and final evaluation | Suja | Correct assigned student; privacy and scale respected | Pending |
| Coordinator checks conditions and approves completion | Ahmad | Missing conditions block approval; approved result follows GradingService | Pending |
| Generate/download official report and certificate | Ahmad | Documents match approved record; unavailable before approval | Pending |
| Student progress/result visibility | Ahmad | Approved hours and allowed results only; no confidential evaluation leakage | Pending |

For each live step, record date, account role, commit, outcome and sanitized evidence.
Do not paste passwords, ID tokens or secret configuration into evidence or issues.

## Regression checks

Run the existing local browser suites against the disposable IIS test host and
Postman stand-in, one at a time: `application`, `application-decisions`,
`offer-confirmation`, `public-layout`, `role-layouts`, `coordinator-monitoring`
(`tests/<name>.browser.js`). Each suite manages local fixtures; do not run them
against a shared database. Keep desktop/mobile and role-denial checks in the demo
review. Then repeat the business flow above against the real team environment
using the normal login; `__fixture.aspx` belongs only to the disposable local host.

Track failures with reproduction steps and the owning page. Mark X06 complete only
when the live flow, PDF outputs, security checks and final demo have passed.
