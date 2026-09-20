---
name: forecast
description: Weekly sales forecast to the manager. Use for "/forecast" (build this week's Best Case / Commit list from Salesforce, let the rep pick, draft the message in the manager's exact format, post to Slack only on explicit confirm) and "/forecast history". Also use when the rep says "what am I forecasting this month" or "send my manager my forecast".
---

# Forecast

Every Wednesday the manager asks for the deals expected to close this month and this quarter, as a Slack message in a fixed format. This skill builds the candidate list from Salesforce, lets the rep choose, drafts the message, and posts it only when told to.

## Files
```
<workspace>/
  templates/forecast-message.md   # the manager's exact format; the rep edits this copy (seed: templates/ next to this SKILL.md)
  forecasts/<YYYY-MM-DD>.md       # what was sent, and the candidate list it was chosen from
  deals/<slug>/DEAL.md            # if a deal room exists, its Summary and Read feed the "why"
```

## `forecast` (default)
1. **Candidates.** Through the Salesforce connector, fetch the rep's open opportunities (owner = me, not closed) with Forecast Category in Commit or Best Case, or Close Date within the current month or current quarter, or Stage at or above the rep's "real" threshold from `deal-judgment.md`. Fields: Opportunity name, Account, Stage, Forecast category, Amount and MRR (or whatever the org's recurring-revenue field is), Close date, Next step, Last activity date, record URL. If the connector is unavailable or the query fails, say so and stop. Never fill the list from memory.
2. **Enrich.** For each candidate with a `deals/<slug>/DEAL.md`, pull one line from its Summary and the latest Commitments entry. For candidates without a room, note "no deal room".
3. **Present** a numbered table: #, Opportunity, MRR, Stage, Forecast cat., Close date, Last activity, Why (one line). Split into "This month" and "This quarter" by close date. Then ask, in one message: which numbers to forecast for this month, which for this quarter, and "anything in your pipeline I missed?" Also flag anomalies: Commit with no activity in 14+ days, close date in the past, Best Case with a next step that says the prospect has gone quiet.
4. **Draft** the message using `templates/forecast-message.md`, one block per chosen deal, in the order the rep gave. Show the full draft.
5. **Send only on an explicit "send".** Post via the Slack connector as a direct message to the manager (name in the template's header). If the Slack connector cannot post, say so and present the draft for copy-paste. Never post to a channel unless the template names one.
6. **Record** `forecasts/<YYYY-MM-DD>.md`: the candidate table, the picks, the message as sent, and the timestamp.

## `forecast history`
List `forecasts/*.md` with the deals forecast each week and whether each has since closed (check Salesforce stage). Useful for "what did I forecast last month that slipped."

## Rules
- If `deal-judgment.md` is missing from the workspace, say "This folder is not set up yet. Run /start first." and stop. Do not scaffold the workspace silently.
- Nothing is sent without the word "send" from the rep in this session.
- Numbers come from Salesforce in this run, never from a previous forecast file.
- The "why" line is the rep's reasoning in his words when a deal room exists; otherwise it is a neutral fact (stage, next step), never invented sentiment.
- If the template still has [FILL] markers, stop and ask for the manager's real format before drafting.
