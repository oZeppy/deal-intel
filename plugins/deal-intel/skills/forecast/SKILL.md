---
name: forecast
description: Weekly sales forecast to the manager. Use for "/forecast" (build this week's Best Case / Commit list from Salesforce, let the rep pick, draft the message in the manager's exact format, post to Slack only on explicit confirm), "/forecast history", and "/forecast help" (the menu). Also use when the rep says "what am I forecasting this month", "send my manager my forecast", or asks what the forecast skill can do.
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

## Help

`/forecast` on its own is not a request for help: it is this skill's default command, so run it, beginning at step 0.

If the rep asks for help / what can you do / options, do not guess and do not start work. Print exactly this menu and stop, then wait for a reply:

> Forecast. Pick one:
> - `/forecast` - build this week's list, pick your deals, draft the message
> - `/forecast history` - what you forecast in past weeks, and whether it closed
>
> Or just say it in plain English, e.g. "what am I forecasting this month".

## `forecast` (default)
0. **Check the format file first, before any Salesforce query.** Read `templates/forecast-message.md`. If the word FILL appears anywhere in that file, do not query Salesforce yet. Name the exact line number and text of each line that still holds FILL (skip the file's own first line, which states this rule rather than needing him), then say: "I can build your candidate list now, but I cannot draft in your manager's real format until templates/forecast-message.md is filled in. Paste the format here and I will save it into the file for you, or say 'use the sample format' and I will draft with the sample layout already in that file so you can see the shape." If he pastes a format, write it into `templates/forecast-message.md` in place of the sample block and the FILL lines, tell him the file is now his own format, and carry on. Continue to step 1 only after he answers.
1. **Candidates.** Through the Salesforce connector, fetch the rep's open opportunities (owner = me, not closed) with Forecast Category in Commit or Best Case, or Close Date within the current month or current quarter, or Stage at or above the rep's "real" threshold from `deal-judgment.md`. Fields: Opportunity name, Account, Stage, Forecast category, Amount and MRR (or whatever the org's recurring-revenue field is), Close date, Next step, Last activity date, record URL. If the Salesforce connection is unavailable or the query fails, say in one line what failed and that no candidate list can be built without it (never from memory), give the rep one line he can copy to whoever set this up, e.g. "Salesforce connection not available in Cowork, 2026-09-20, could not build this week's forecast.", and stop.
2. **Enrich.** For each candidate with a `deals/<slug>/DEAL.md`, pull one line from its Summary and the latest Commitments entry. For candidates without a room, note "no deal room".
3. **Present** a numbered table with these plain-word columns: #, Deal, Monthly value, Stage, Category, Close date, Last touched, Why. Split it into "This month" and "This quarter" by close date. Fold every anomaly into that row's Why line as a leading "Watch: ..." clause (for example "Watch: no activity in 14+ days." for a Commit gone quiet, a close date in the past, or a Best Case whose next step says the prospect has gone silent) instead of listing anomalies separately. Then ask one question with a worked example: "Which of these are you forecasting? Reply like: month 1,3,4 / quarter 7. Add anything I missed."
4. **Draft** the message using `templates/forecast-message.md`, one block per chosen deal, in the order the rep gave. If he chose the sample format at step 0, use the sample layout already present in that file. Show the full draft.
5. **Confirm, then send, then say you sent.** Before posting, print one line naming the recipient and the totals: "Ready to send to @dana-m as a direct message: 4 deals, $38,400 MRR this month, 2 more this quarter. Type send to post it, or tell me what to change." Post only on the confirmation described in the Rules. Post via the Slack connector as a direct message to the manager (the handle in the template's header). If the Slack connection cannot post, say so and present the draft for copy-paste. Never post to a channel unless the template names one. After posting, print the receipt: "Sent to @dana-m at 10:02. A copy is saved in forecasts/2026-09-23.md."
6. **Record** `forecasts/<YYYY-MM-DD>.md`: the candidate table, the picks, the message as sent, and the timestamp.

## `forecast history`
List `forecasts/*.md` with the deals forecast each week and whether each has since closed (check Salesforce stage). Useful for "what did I forecast last month that slipped."

## Rules
- **Check the folder before doing anything.** The working folder must hold `deal-judgment.md` and a `deals/` folder. If either is missing, create nothing and write nothing: say "This folder is not set up yet. Run /start first. I am working in <absolute path>. That does not look like your Deals workspace. Open the Deals folder in Cowork, or say 'set up here' and I will run /start." and stop. Do not scaffold the workspace silently.
- Begin the first line of every command's output with "workspace: <absolute path>".
- End every run with a single line starting "Next:" offering the one step that most likely follows. After a draft: "Next: type send, or tell me what to change." Never more than one line, never a menu.
- **Post only on a bare confirmation of a draft already shown in full in this session**, where the rep's whole message is "send", "send it" or "yes send" and nothing else. Any other sentence that happens to contain the word is not a confirmation: answer it and do not post. Immediately before posting, print "Posting the draft above to <resolved handle> as a Slack direct message." If the handle is still a FILL marker, stop and ask who it goes to.
- Numbers come from Salesforce in this run, never from a previous forecast file, and never from memory.
- The "why" line is the rep's reasoning in his words when a deal room exists; otherwise it is a neutral fact (stage, next step), never invented sentiment.
- Never invent a Salesforce value. A field you could not read is said to be missing, never guessed.
