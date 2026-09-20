---
name: closed-lost
description: Closed-lost nurture tracker. Use for "/closed-lost" on its own or "/closed-lost help" (the menu), "/closed-lost sync" (pull opportunities newly moved to Closed Lost from Salesforce into a triage queue), "/closed-lost triage" (sort the queue into priority / nurture / rejected with a revisit date), "/closed-lost due" (what to re-engage in the next two weeks), and "/closed-lost list". Also use when the rep asks "which closed-lost deals should I be reaching out to", says the tracker stopped syncing, or asks for help or options.
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
Each entry is one table row: Closed date | Opportunity | Account | MRR | Their timeline | Interest | Loss reason | Revisit date | Salesforce link | Note.

## No subcommand, or help

If the rep types the skill name alone, or says help / what can you do / options, do not guess and do not start work. Print exactly this menu and stop, then wait for a reply:

> Closed-lost deals. Pick one:
> - `/closed-lost sync` - pull deals Salesforce just marked closed lost
> - `/closed-lost triage` - sort the queue into priority, nurture or rejected
> - `/closed-lost due` - who to re-engage in the next two weeks
> - `/closed-lost list` - counts, and the ten most recent in each file
>
> Or just say it in plain English, e.g. "who should I be calling back".

## `sync`
1. Read `state.json`. If it is missing, create it with `last_sync` = 180 days ago, and say in the status line that this first run looked back 180 days.
2. Through the Salesforce connector, fetch the rep's opportunities with Stage = Closed Lost and (Close date or Last modified) after `last_sync`, excluding ids in `seen_ids`. Pull: name, account, amount/MRR, close date, the closed-lost "timeline" and "interest" fields, loss reason, record URL.
3. Append new rows to `queue.md`; add ids to `seen_ids`; set `last_sync` to now.
4. Report the count added. If the query fails, change nothing (do not clear the queue), say exactly what failed, and end with the one forwardable failure line from the Rules below, so the rule and the status line agree.

## `triage`
Walk `queue.md` top to bottom. For each row show the facts and ask: priority, nurture, or reject. Move the row to the matching file. Set the revisit date from what they said about timing: "Q1" means the first business day of that quarter; "next month" means the first of next month; "6 months" means today plus 180 days; free text means ask. Keep the rep's one-line note ("partner died, buying after"). Rejected rows are kept, never deleted.

If `queue.md` has no rows, say "Queue is empty. priority N, nurture N, rejected N. Run /closed-lost sync to pull new closed-lost deals, or /closed-lost due to see who to re-engage."

The rep can stop at any point by saying "stop", "stop for now" or "that's enough". Keep every row already sorted exactly where it went, leave the rest in `queue.md` untouched, and say how many are left: "Stopped. 4 sorted, 11 still in the queue. Run /closed-lost triage when you want to carry on."

## `due`
List priority and nurture rows whose revisit date is within the next 14 days, or already past, oldest first, with the note and the link. Offer to draft a re-engagement message for any of them (draft only; never send).

## `list`
Counts per file, and the ten most recent in each.

## Rules
- **Check the folder before doing anything.** The working folder must hold `deal-judgment.md` and a `closed-lost/` folder. If either is missing, create nothing and write nothing: say "This folder is not set up yet. Run /start first. I am working in <absolute path>. That does not look like your Deals workspace. Open the Deals folder in Cowork, or say 'set up here' and I will run /start." and stop. Do not scaffold the workspace silently.
- Begin the first line of every command's output with "workspace: <absolute path>".
- Every command ends with one status line the rep can read at a glance, in plain words, built from the real values:
  - it worked: `closed-lost: 4 new since your last check (Sep 13). No problems.`
  - it did not: `closed-lost: could not reach Salesforce, nothing changed in your files. Please send this line to whoever set this up: <the exact error text>`. The error text is copied verbatim from the connector, never summarised and never invented. Name no person.
  A run that cannot reach Salesforce says so in that line; silence is never success. Zero new is a normal answer, not a failure.
- End every run with a single line starting "Next:" offering the one command that most likely follows, in backticks. After `sync`: "Next: `/closed-lost triage`." Never more than one line, never a menu.
- Never send anything. Never delete rows. Never re-add an id already in `seen_ids`.
- Never invent a Salesforce value. A field you could not read is left blank and said to be blank.
- If the timeline field is named differently in the rep's org, record the real Salesforce field name in `state.json` under `"fields"` after the first successful sync and use it thereafter. That is bookkeeping; never show it to the rep.
- When the rep says "it stopped working", run `sync`, show the exact error, and fix the query, not the files.
