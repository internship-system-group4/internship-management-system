# Internship application simulation

## Purpose

Run the actual Web Forms application against the Firebase REST stand-in in
`../mocks/firebase/default.js`. The simulation does not replace the application.

## Run

Start `postman simulation run postman/simulations/internship-application.sim.yaml --port 4920 --output ndjson`.
Use `tests/Start-ApplicationTestHost.ps1 -SimulationPort 4920` for a disposable
authenticated IIS copy. Set `Firebase.ReadCacheSeconds=0` in that copy to measure
uncached calls, then navigate Playwright to the host and run
`tests/application-review-loading.browser.js`. The test resets the synthetic database;
run it independently of other tests using this simulation.

## Assumptions

- Local timing cannot predict deployed Firebase latency or verify production
  database security rules (observed 2026-10-24). The mock models the REST shapes
  in its handler; it is not the Firebase rules engine.

## What didn't work

- A temporary host may load `App_Secrets.config` after inline app settings.
  Updating only the inline database URL left the application using the previous
  simulation. Update the temporary override and recycle the host before testing
  against another port (observed 2026-10-24).

## Observations

<!-- begin:observations -->
2026-10-24: The Firebase member served actual application reads and decision writes.
The loading regression verified deferred profile reads, successful accept/reject
postbacks, detail-load retry, retained unsaved rejection input, Arabic mobile
layout, and company isolation in application code. These are local simulation
results; live Firebase performance and rule enforcement remain unverified.
<!-- end:observations -->
