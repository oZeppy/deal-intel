---
name: deal-room
description: Per-opportunity deal room kept as a folder. Use for "/deal-room" on its own, "/deal-room help", "/deal-room new <opportunity>", "/deal-room ingest" (file transcripts from inbox/ into the right deal and update its brief), "/deal-room sync <opportunity>" (pull new Gong call activity from Salesforce), "/deal-room ask <opportunity> <question>", "/deal-room show <opportunity>" (read the brief as it stands), "/deal-room refresh <opportunity>" (rebuild the brief), "/deal-room list". Also use when the user drops a call transcript and wants it filed, asks what a prospect said on a call, or asks for help or options.
---

# Deal room

One folder per Salesforce opportunity. Raw material (transcripts, Gong summaries, emails) goes in; a living brief (`DEAL.md`) and structured call notes come out. Everything is plain markdown so the rep can read, fix, and move it.

## Workspace layout

```
<workspace>/
  deal-judgment.md            # the rep's own decision criteria; read it before writing any assessment
  inbox/                      # drop zone: transcripts downloaded from Gong, pasted notes, emails
  deals/<slug>/
    DEAL.md                   # living brief (template: templates/DEAL.md in this plugin)
    calls/<YYYY-MM-DD>-<title>.md          # the full transcript, verbatim, never edited
    calls/<YYYY-MM-DD>-<title>.notes.md    # structured notes extracted from that transcript
    notes/                    # anything else: emails, pricing sent, internal threads
```

The deal folder name is the opportunity name lower-cased with non-alphanumerics turned into `-`, e.g. `pinecrest-family-law-group`. That is an internal detail; never use the word "slug" when talking to the rep.

## No subcommand, or help

If the rep types the skill name alone, or says help / what can you do / options, do not guess and do not start work. Print exactly this menu and stop, then wait for a reply:

> Deal rooms. Pick one:
> - `/deal-room list` - what deals do I have
> - `/deal-room new <opportunity>` - start a room from Salesforce
> - `/deal-room ingest` - file whatever is in inbox/
> - `/deal-room ask <deal> <question>` - what did they say about X
> - `/deal-room show <deal>` - read the brief
> - `/deal-room refresh <deal>` - rebuild the brief from the filed calls and Salesforce
> - `/deal-room sync <deal>` - pull new call activity from Salesforce
>
> Or just say it in plain English, e.g. "catch me up on Pinecrest".

## Finding the deal the rep meant

`ask`, `sync`, `show` and `refresh` all take `<opportunity>`. Resolve it before running the command's own steps. Try the exact folder name, then a case-insensitive substring match against the folder names under `deals/` and the Account line of each `DEAL.md`. Any substring match counts ("pinecrest" matches `pinecrest-family-law-group`).

- Exactly one match: use it, and name it in the first line of the answer ("Pinecrest Family Law Group, from 2 filed calls:").
- Several matches: list them as numbered choices with account and last call date, "none of these" last, and ask which one. Never guess.
- No name given: if exactly one deal folder exists, use it and say so; otherwise list the folders and ask which.
- No match: say "No deal folder named <what was typed>. Deals on file: <list them, or say none yet>. Run `/deal-room new <opportunity>` to create one." Write nothing.

Never answer "not in the filed calls" when no folder matched; that sentence is reserved for a folder that exists but does not hold the answer. Never answer from a folder you did not name in the answer.

## Commands

### `new <opportunity name or Salesforce link>`
1. **Check the folder does not already exist.** If it does, write nothing and stop the write path: report "Room already exists: N calls filed, brief last updated <date>." (read the count from `calls/` and the date from the existing `DEAL.md`) and offer `/deal-room ingest` or `/deal-room refresh <opportunity>` instead.
2. Look the opportunity up through the Salesforce connector (by name, or by the 15/18-character id in the link). Pull: Account name, Opportunity name, Owner, Stage, Amount / MRR, Close date, Forecast category, Next step, Created date, Lead source, any custom fields that describe firm size or practice area, and the record URL. If the Salesforce connection is not available in this session, follow the missing-connection rule below and ask the rep only for stage, monthly value and close date; every other field is optional and skippable. Never invent a value.
3. Create `deals/<slug>/` with `calls/` and `notes/`.
4. Write `DEAL.md` from `templates/DEAL.md` (next to this SKILL.md): fill the header fields you have, print the one "Still needed from Salesforce" line for the ones you do not, and leave the rest as "No calls filed yet."
5. If `inbox/` contains files that mention this account, offer to ingest them now.

### `ingest`
For every file in `inbox/` (transcripts, Gong summary emails, pasted notes):
1. **Identify the opportunity.** If `inbox/` is missing or holds no files, say "inbox is empty (<absolute path>). Nothing to file. Drop a transcript in and run /deal-room ingest again.", create nothing, and look nowhere else. Otherwise match the account or firm name in the filename or the first 60 lines, including participant email domains, against `deals/*/DEAL.md` (the Account line). If exactly one match, use it. Never guess.

   When no single match is found, first show the rep what you saw: the filename, the participant names and email domains found in the first 60 lines, and the first two lines a speaker said. Then list the existing deal folders as a numbered menu and ask in these words, with the real names swapped in:

   > I found a transcript for Pinecrest Family Law Group in your inbox. I do not have a deal folder for it yet, and Salesforce did not return a match. What would you like me to do?
   > 1. Create the folder and file the call now. The brief will show Stage, MRR and close date as still needed until Salesforce has them. (Recommended)
   > 2. Tell me the stage, monthly value and close date yourself and I will fill them in.
   > 3. Leave it alone. The file stays in your inbox and I write nothing.

   He can also type an opportunity name, which runs `new` (that looks it up in Salesforce before creating the folder). When several deals match, list them as numbered choices with account and last call date, "none of these" last. If the date of the call is also unknown, ask for it in the same message, never as a second question afterwards.
2. **Read the whole file before writing anything.** Transcripts run 30 minutes to 2 hours (up to ~25k words). Read in sequential chunks with offsets until you reach the end. If you cannot read the entire file, stop and tell the rep which file and how far you got. A partial read must never produce notes; a wrong "they said X" is worse than no notes.
3. Move the file to `deals/<slug>/calls/<YYYY-MM-DD>-<short-title>.md` (date from the file, its name, or the Gong header; ask if absent). Do not alter its contents.
4. Write `<same name>.notes.md` using `templates/call-notes.md` next to this SKILL.md. Every fact carries the speaker and a short verbatim quote. Sections, in the template's order: the four lines that matter (at most four); participants and roles; firm facts (attorneys, staff, practice areas, locations, current software, billing model); stated timeline and triggers; budget, pricing and terms discussed; objections and concerns, four lines each (the objection and who raised it, what they said, what we said, status); competitors named; decisions made; next steps with owner and date; open questions.
5. **Update `DEAL.md`**: append a row to the Call log; merge new facts into Firm facts, Timeline, Stakeholders, Objections and risks, Competitors, Commitments; rewrite the Summary (five one-line bullets, per the `DEAL.md` template) and the "Read" section using `deal-judgment.md`. Keep earlier facts unless a later call supersedes them, and mark supersession ("was Q4, now Q1 per 2026-09-10 call").
6. **Close with three short parts**, in plain words and in this order:
   - what happened: "Filed 1 call into Pinecrest Family Law Group: 2026-09-10 discovery call, 9 minutes, moved out of your inbox"
   - what changed: "Updated the brief: 6 new firm facts, 4 stakeholders, 5 commitments, 1 competitor"
   - what next: "Open deals/pinecrest-family-law-group/DEAL.md, or ask me: /deal-room ask Pinecrest what did they say about pricing"

   Anything you could not place gets its own line naming the file and the one question that would place it.

### `sync <opportunity>`
Pull new Gong call activity for this opportunity from Salesforce since the last Call log entry. What Salesforce actually holds (verified against Gong's documentation, 2026-09-17):
- If the org has the **Gong for Salesforce** package, each call is a **Gong Conversation** record (custom object) with fields including Call Brief (a short AI summary), Call Highlights - Next Steps, Call Key Points, Call Outcome, Duration, Participants Emails, a Primary Opportunity lookup, related-opportunity junction records, and a URL to the call in Gong. **No field holds the transcript text**; the Transcript tab in Salesforce is a Gong-rendered canvas, not stored data, so no connector can read it.
- If the org only has Gong's activity export, each call is a Task or Event with participants and a link, and no transcript.
Procedure:
1. Query Gong Conversation records whose Primary Opportunity is this opportunity (fall back to related-opportunity records, then to Tasks/Events on the opportunity with a gong.io link). Gong links calls to opportunities by best-effort email/domain matching, so also list calls on the same Account that carry a different or blank Primary Opportunity and ask before filing them.
2. For each new call, write `calls/<date>-<title>.gong-summary.md` containing every field verbatim (brief, key points, next steps, outcome, participants, duration, Gong URL) and add a Call log row marked "summary only".
3. Merge the summary facts into `DEAL.md` the same way as ingest, but tag each such fact "(Gong summary, not transcript)". Never present a summary as a transcript.
4. End by listing the Gong URLs of calls that have no full transcript filed, so the rep can download each transcript (Gong call page > More actions > Download transcript, if their permission profile allows it) into `inbox/` and run `ingest`.
5. Two different endings, and they must not be confused:
   - The Salesforce connection is missing, or the connector exposes no Gong records at all: use the missing-connection rule below, then stop.
   - Salesforce answered and this opportunity simply has no Gong call records: say "No call activity in Salesforce for this deal. That is normal if your org does not have the Gong package. Nothing is wrong." and stop.

### `ask <opportunity> <question>`
Resolve the deal first, as above. Answer from that deal folder only. Search the `.notes.md` files first, then the full transcripts for anything the notes lack. Cite every answer: file, date, speaker, and the quote. If the folder exists but does not contain the answer, say "not in the filed calls" and name the calls that exist. Do not answer from general knowledge about the firm.

### `show <opportunity>`
Resolve the deal first, as above. Print the current `DEAL.md` unchanged: no rebuild, no edit, nothing written. End with exactly one line:

> Out of date? Run `/deal-room refresh <opportunity>` to rebuild it from the filed calls and Salesforce.

`brief <opportunity>` is an older name for `show`. Treat it as `show` and never as a rebuild.

### `refresh <opportunity>`
Rebuild `DEAL.md` from scratch: refresh the Salesforce fields through the connector, re-read every `.notes.md`, and rewrite all sections. Use when the brief has drifted or after a manual edit to the notes.
1. **Ask before overwriting.** Say that this rebuilds `DEAL.md` from Salesforce and the filed call notes, and that any line the rep typed straight into `DEAL.md` which is not in a notes file will be lost. Then compare the current `DEAL.md` against the `.notes.md` files and the Salesforce fields it should have been built from: if any section holds text that is not traceable to a `.notes.md` file or to Salesforce, quote those lines back to the rep and ask before overwriting. Offer to show the changes first. On "no", stop and say to copy that text into `deal-judgment.md` or a notes file first.
2. **Only rewrite after the rep confirms.** Before touching the original, copy it to `notes/DEAL-<YYYY-MM-DD-HHMM>.md`; do not delete or overwrite the original until that copy is written.
3. Rewrite every section from the notes and the Salesforce fields, using `templates/DEAL.md`.
4. **Close with 3 to 5 lines of what actually changed** ("Stage moved to 4, 2 new commitments, Read section now cites rule 18"), and name the backup file so the rep knows where any hand edit went.

### `list`
Table of all deal folders: opportunity, stage, close date, last call date, number of calls, one-line summary. Flag rooms with no call in 21+ days.

## Writing the "Read" section (thinking like the rep)
Read `deal-judgment.md` first, every time. It holds the rep's own rules for what makes a deal real, how they read stages, and how the rep wants close probability reasoned. Apply those rules explicitly: "Per your rule 3 (a partner on the call who asks about migration = real), this is real; per rule 7, a stated Q1 timeline with no budget owner is Best Case, not Commit." Never output a bare probability number. If the rules do not cover the situation, say which rule is missing so the rep can add it.

Before writing the first assessment of a session, scan `deal-judgment.md` for `[FILL]` markers and for rule text that still reads like the shipped starter example rather than the rep's own words. If any are found, say so once per session: name the specific rule numbers that are still blank, and separately name any rules you are relying on that look like unedited starter content. Offer to write their real rules into the file from what he tells you now. When an assessment then cites a rule flagged this way, add "(placeholder rule, not yet yours)" after the citation instead of citing it as settled fact. Do not hardcode rule numbers here; name whatever you find in their actual file.

## Rules
- **Check the folder before doing anything.** The working folder must hold `deal-judgment.md` and a `deals/` folder. If either is missing, create nothing and write nothing: say "This folder is not set up yet. Run /start first. I am working in <absolute path>. That does not look like your Deals workspace. Open the Deals folder in Cowork, or say 'set up here' and I will run /start." and stop. Do not scaffold the workspace silently.
- Begin the first line of every command's output with "workspace: <absolute path>".
- End every run with a single line starting "Next:" offering the one command that most likely follows, in backticks, with the deal name filled in. After filing a transcript: "Next: `/deal-room ask <deal> <your question>`, or `/deal-room show <deal>` to read the brief." After `list`: the oldest stale room. Never more than one line, never a menu.
- **When the Salesforce or Gong connection is missing, or a query comes back with nothing**, say in one line which connection and what that means, then give two numbered choices: (1) carry on without it, naming exactly which fields will be left blank, or (2) stop here. End with one line the rep can copy to whoever set this up, e.g. "Salesforce connection not available in Cowork, 2026-09-20."
- Never rewrite a file the rep may have hand-edited without saying so first and getting a go-ahead.
- Never send anything anywhere from this skill. It only reads connectors and writes files in the workspace.
- Never modify a transcript. Never delete files; move them.
- Never invent a Salesforce value. A field you could not read is "still needed", never a guess.
- Prefer the rep's words over paraphrase in notes. Quotes are the evidence.
- If Salesforce returns nothing for a name, try the Account name and the first two words; then ask. Whenever a match is ambiguous, ask.
- Full transcripts reach this workspace only by the rep downloading them from Gong into `inbox/` (or, if the org has enabled Claude in Chrome for gong.io, by the rep asking Claude in Chrome to save the open call's transcript into `inbox/`). Never try to fetch a Gong URL yourself; the connectors cannot, and the skill must not work around access controls.
