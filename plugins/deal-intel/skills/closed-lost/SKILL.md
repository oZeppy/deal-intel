---
name: closed-lost
description: Closed-lost nurture tracker. Use for "/closed-lost sync" (pull opportunities newly moved to Closed Lost from Salesforce into a triage queue), "/closed-lost triage" (sort the queue into priority / nurture / rejected with a revisit date), "/closed-lost due" (what to re-engage in the next two weeks), and "/closed-lost list". Also use when the rep asks "which closed-lost deals should I be reaching out to" or says the tracker stopped syncing.
---

# Closed-lost tracker

Closed-lost deals in mid-market are the pipeline of next year: "they chatted with you in September but were ready to evaluate in January." Salesforce closes them and they vanish from the working views. This skill keeps a plain-markdown queue the rep triages and a due list he checks weekly.

## Files
```
<workspace>/closed-lost/
  state.json      # {"last_sync": "<ISO timestamp>", "seen_ids": [...]}
  queue.md        # untriaged, newest first
  priority.md     # will buy; revisit date set
  nurture.md      # keep warm; revisit date set
  rejected.md     # bad fit; kept so it never re-enters the queue
```
Each entry is one table row: Closed date | Opportunity | Account | MRR | Timeline picklist | Interest | Loss reason | Revisit date | Salesforce link | Note.

## `sync`
1. Read `state.json` (create it with `last_sync` = 30 days ago if missing).
2. Through the Salesforce connector, fetch the rep's opportunities with Stage = Closed Lost and (Close date or Last modified) after `last_sync`, excluding ids in `seen_ids`. Pull: name, account, amount/MRR, close date, the closed-lost "timeline" and "interest" picklists, loss reason, record URL.
3. Append new rows to `queue.md`; add ids to `seen_ids`; set `last_sync` to now.
4. Report the count added. If the connector query fails, say exactly what failed (object, field, error text) and change nothing; do not clear the queue.

## `triage`
Walk `queue.md` top to bottom. For each row show the facts and ask: priority, nurture, or reject. Move the row to the matching file. Set the revisit date from the timeline picklist: "Q1" means the first business day of that quarter; "next month" means the first of next month; "6 months" means today plus 180 days; free text means ask. Keep the rep's one-line note ("partner died, buying after"). Rejected rows are kept, never deleted.

## `due`
List priority and nurture rows whose revisit date is within the next 14 days, or already past, oldest first, with the note and the link. Offer to draft a re-engagement message for any of them (draft only; never send).

## `list`
Counts per file, and the ten most recent in each.

## Rules
- Every command ends with one status line the rep can read at a glance: `closed-lost: synced N new · last_sync <timestamp> · errors: none` (or the exact error). A run that cannot reach Salesforce says so in that line; silence is never success.
- Never send anything. Never delete rows. Never re-add an id already in `seen_ids`.
- If the timeline picklist name differs in the rep's org, record the real API name in `state.json` under `"fields"` after the first successful sync and use it thereafter.
- When the rep says "it stopped working", run `sync`, show the exact connector error, and fix the query, not the files.
