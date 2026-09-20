---
name: start
description: First-run setup for the deal workspace. Use for "/start", "set up my deals folder", "get started", "how do I begin". Creates inbox/, deals/, closed-lost/, forecasts/, templates/forecast-message.md and deal-judgment.md in the current folder, drops a sample transcript so the first test needs no Salesforce, and lists the three commands to try.
---

# Start

Turns the folder Claude is working in into a deal workspace. Run once, the first time. Nothing is sent anywhere; nothing existing is ever deleted or overwritten.

## What the workspace is

```
<workspace>/
  deal-judgment.md                # the rep's own decision rules; every skill reads it first
  templates/forecast-message.md   # the manager's exact forecast format
  inbox/                          # drop zone for transcripts downloaded from Gong
  deals/<slug>/                   # one folder per opportunity
  closed-lost/                    # the nurture queue
  forecasts/                      # what was sent each week
```

## Procedure

1. **Say where you are.** State the full path of the folder you are working in, so the rep can stop you if it is the wrong one. Then look at what is already there. If it holds files that are not part of this workspace (anything other than the folders and files listed above, ignoring `.DS_Store` and `.gitkeep`), list them and ask whether to set the workspace up here before writing anything. If the folder is empty, or holds only workspace items, carry on.
2. **Create the folders**: `inbox/`, `deals/`, `closed-lost/`, `forecasts/`. If one exists, leave it and its contents alone.
3. **Create the two files.** Write `deal-judgment.md` from `templates/deal-judgment.md` next to this SKILL.md, and `templates/forecast-message.md` from `templates/forecast-message.md` next to this SKILL.md. **Never overwrite.** If either file already exists, keep the rep's version untouched and say which one you kept.
4. **Drop the sample transcript.** Unless `deals/pinecrest-family-law-group/` already exists, write `inbox/SAMPLE (not real) - 2026-09-10 Pinecrest Family Law Group - discovery call.md` from `templates/sample-transcript.md` next to this SKILL.md, byte for byte, no edits. Pinecrest is an invented firm, so the first test needs no Salesforce. If that deal folder exists, skip this step and say so.
5. **Finish with a short "Next" block**, in plain language, no jargon, four steps:
   - Run `/deal-room ingest`. It will ask what to do about Pinecrest, because it is not in Salesforce; the recommended option is fine.
   - Then run `/deal-room ask Pinecrest what did they say about their LedgerLaw renewal`.
   - Then delete the `deals/pinecrest-family-law-group` folder. It is made up.
   - Then, when ready, fill in `deal-judgment.md` in your own words and paste your manager's real format over `templates/forecast-message.md`.

   End the block by mentioning that typing `/` lists the skills.

## Rules
- Never delete or overwrite an existing file. Report what you kept instead.
- Never send anything anywhere. This skill only writes files in the folder Claude is working in.
- Write the templates verbatim. Do not improve the wording or fill the `[FILL]` markers; those are the rep's to fill.
- Do not create a deal room, do not ingest anything, do not touch a connector. This skill only scaffolds.
