---
name: deal-room
description: Per-opportunity deal room kept as a folder. Use for "/deal-room new <opportunity>", "/deal-room ingest" (file transcripts from inbox/ into the right deal and update its brief), "/deal-room sync <opportunity>" (pull new Gong call activity from Salesforce), "/deal-room ask <opportunity> <question>", "/deal-room brief <opportunity>", "/deal-room list". Also use when the user drops a call transcript and wants it filed, or asks what a prospect said on a call.
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

`<slug>` is the opportunity name lower-cased, non-alphanumerics to `-`, e.g. `pinecrest-family-law-group`.

## Commands

### `new <opportunity name or Salesforce link>`
1. Look the opportunity up through the Salesforce connector (by name, or by the 15/18-character id in the link). Pull: Account name, Opportunity name, Owner, Stage, Amount / MRR, Close date, Forecast category, Next step, Created date, Lead source, any custom fields that describe firm size or practice area, and the record URL. If the connector is not available in this session, say so and ask the rep for those fields; do not invent them.
2. Create `deals/<slug>/` with `calls/` and `notes/`.
3. Write `DEAL.md` from `templates/DEAL.md` (next to this SKILL.md), filling the Salesforce block and leaving the rest as "No calls filed yet."
4. If `inbox/` contains files that mention this account, offer to ingest them now.

### `ingest`
For every file in `inbox/` (transcripts, Gong summary emails, pasted notes):
1. **Identify the opportunity.** Match the account or firm name in the filename or the first 40 lines against `deals/*/DEAL.md` (the Account line). If exactly one match, use it. If none or several, ask the rep, and offer `new` if the deal has no room yet. Never guess.
2. **Read the whole file before writing anything.** Transcripts run 30 minutes to 2 hours (up to ~25k words). Read in sequential chunks with offsets until you reach the end. If you cannot read the entire file, stop and tell the rep which file and how far you got. A partial read must never produce notes; a wrong "they said X" is worse than no notes.
3. Move the file to `deals/<slug>/calls/<YYYY-MM-DD>-<short-title>.md` (date from the file, its name, or the Gong header; ask if absent). Do not alter its contents.
4. Write `<same name>.notes.md` using `templates/call-notes.md` next to this SKILL.md. Every fact carries the speaker and a short verbatim quote. Sections: participants and roles; firm facts (attorneys, staff, practice areas, locations, current software, billing model); stated timeline and triggers; budget, pricing and terms discussed; objections and concerns; competitors named; decisions made; next steps with owner and date; open questions; notable quotes.
5. **Update `DEAL.md`**: append a row to the Call log; merge new facts into Firm facts, Timeline, Stakeholders, Objections and risks, Competitors, Commitments; rewrite the Summary (5 lines max) and the "Read" section using `deal-judgment.md`. Keep earlier facts unless a later call supersedes them, and mark supersession ("was Q4, now Q1 per 2026-09-10 call").
6. Report: files filed, per deal, and anything you could not place.

### `sync <opportunity>`
Pull new Gong call activity for this opportunity from Salesforce since the last Call log entry. What Salesforce actually holds (verified against Gong's documentation, 2026-09-17):
- If the org has the **Gong for Salesforce** package, each call is a **Gong Conversation** record (custom object) with fields including Call Brief (a short AI summary), Call Highlights - Next Steps, Call Key Points, Call Outcome, Duration, Participants Emails, a Primary Opportunity lookup, related-opportunity junction records, and a URL to the call in Gong. **No field holds the transcript text**; the Transcript tab in Salesforce is a Gong-rendered canvas, not stored data, so no connector can read it.
- If the org only has Gong's activity export, each call is a Task or Event with participants and a link, and no transcript.
Procedure:
1. Query Gong Conversation records whose Primary Opportunity is this opportunity (fall back to related-opportunity records, then to Tasks/Events on the opportunity with a gong.io link). Gong links calls to opportunities by best-effort email/domain matching, so also list calls on the same Account that carry a different or blank Primary Opportunity and ask before filing them.
2. For each new call, write `calls/<date>-<title>.gong-summary.md` containing every field verbatim (brief, key points, next steps, outcome, participants, duration, Gong URL) and add a Call log row marked "summary only".
3. Merge the summary facts into `DEAL.md` the same way as ingest, but tag each such fact "(Gong summary, not transcript)". Never present a summary as a transcript.
4. End by listing the Gong URLs of calls that have no full transcript filed, so the rep can download each transcript (Gong call page > More actions > Download transcript, if his permission profile allows it) into `inbox/` and run `ingest`.
5. If the connector exposes no Gong objects and no call activity, say so and stop.

### `ask <opportunity> <question>`
Answer from the deal folder only. Search the `.notes.md` files first, then the full transcripts for anything the notes lack. Cite every answer: file, date, speaker, and the quote. If the folder does not contain the answer, say "not in the filed calls" and name the calls that exist. Do not answer from general knowledge about the firm.

### `brief <opportunity>`
Rebuild `DEAL.md` from scratch: refresh the Salesforce block through the connector, re-read every `.notes.md`, and rewrite all sections. Use when the brief has drifted or after a manual edit to the notes.

### `list`
Table of all deal folders: opportunity, stage, close date, last call date, number of calls, one-line summary. Flag rooms with no call in 21+ days.

## Writing the "Read" section (thinking like the rep)
Read `deal-judgment.md` first, every time. It holds the rep's own rules for what makes a deal real, how he reads stages, and how he wants close probability reasoned. Apply those rules explicitly: "Per your rule 3 (a partner on the call who asks about migration = real), this is real; per rule 7, a stated Q1 timeline with no budget owner is Best Case, not Commit." Never output a bare probability number. If the rules do not cover the situation, say which rule is missing so the rep can add it.

## Rules
- If `deal-judgment.md` is missing from the workspace, say "This folder is not set up yet. Run /start first." and stop. Do not scaffold the workspace silently.
- Never send anything anywhere from this skill. It only reads connectors and writes files in the workspace.
- Never modify a transcript. Never delete files; move them.
- Prefer the rep's words over paraphrase in notes. Quotes are the evidence.
- If the Salesforce connector returns nothing for a name, try the Account name and the first two words; then ask.
- Full transcripts reach this workspace only by the rep downloading them from Gong into `inbox/` (or, if the org has enabled Claude in Chrome for gong.io, by the rep asking Claude in Chrome to save the open call's transcript into `inbox/`). Never try to fetch a Gong URL yourself; the connectors cannot, and the skill must not work around access controls.
