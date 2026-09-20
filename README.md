# deal-intel

Three Claude skills for a mid-market account executive at a legal-software vendor, built to run inside a company-provisioned Claude seat using only the connectors the company already enabled (Salesforce, Slack, Gmail). No API keys, no external services, nothing leaves Claude and the rep's own folder.

| Skill | What it does | Trigger |
|---|---|---|
| `start` | First-run setup: creates the workspace folders, `deal-judgment.md` and `templates/forecast-message.md` in the current folder, plus a synthetic sample transcript to test on. Never overwrites. | `/start` |
| `deal-room` | One folder per opportunity. Files Gong transcripts from `inbox/`, writes structured call notes with quotes, keeps a living brief (`DEAL.md`), answers "what did they say about X" with citations. | `/deal-room new`, `ingest`, `sync`, `ask`, `brief`, `list` |
| `forecast` | Builds the Wednesday Best Case / Commit list from Salesforce, the rep picks, drafts the manager's exact format, posts to Slack only on "send". | `/forecast` (or a Cowork scheduled task, Wednesdays) |
| `closed-lost` | Pulls newly closed-lost opportunities into a triage queue; priority / nurture / reject with revisit dates; `due` lists what to re-engage. | `/closed-lost sync`, `triage`, `due`, `list` |

The three working skills read `deal-judgment.md`, the rep's own rules, before writing any assessment; if it is missing they say the folder is not set up and stop, rather than scaffolding silently. That file is where "make it think like me" lives.

## Repository layout

This repo is a plugin marketplace: `.claude-plugin/marketplace.json` at the root lists one plugin, `deal-intel`, whose own manifest and skills live under `plugins/deal-intel/` (`.claude-plugin/plugin.json` and `skills/`). The version in `plugins/deal-intel/.claude-plugin/plugin.json` is the single source of truth; the marketplace entry deliberately carries none.

## Install (Cowork)

Verified against Anthropic's pages on 2026-09-20 (the Cowork plugin guide, the "Use plugins in Claude" help article, the Claude Code plugin and marketplace references). The rep-facing version is `TRY-IT.md`.

**Route A: GitHub marketplace (updates in one click).** Needs this repo public on GitHub: no official page documents authentication for a private repo added by a user inside Cowork (the credential paths exist only in the Claude Code terminal, and the admin-managed route needs an org Owner and the Claude GitHub App).

1. Claude Desktop → **Customize** → **Plugins** → the Add control (**+** or an **Add** menu, depending on the app version) → **Add marketplace** → **Add from a repository** → `https://github.com/<owner>/<repo>` or `<owner>/<repo>`.
2. **Browse plugins** → `deal-intel` → **Install**. Plugins added this way are saved locally on the machine.
3. Updates: **Update** on the marketplace pulls what was pushed; Cowork also checks on its own (interval undocumented). The new version applies at the next session, no restart. There is no rollback on the rep's side: fix forward with a revert, a version bump, and Update.

Releasing: bump `version` in `plugins/deal-intel/.claude-plugin/plugin.json` (it is the update cache key; a push with the same version is invisible), run `claude plugin validate .`, merge to the default branch (Cowork fetches no other branch or tag), then tell the rep to click Update.

Blockers to expect: no **Add marketplace** control (a Team/Enterprise Owner setting; Claude for Government documents a "Let members add plugin marketplaces" switch that is off by default, and claude.ai's equivalent is undocumented), or github.com unreachable from the device on the corporate network (the fetch runs on the device, outside Cowork's egress allowlist).

**Route B: zip upload (fallback; no update channel).** `./package.sh` builds `dist/deal-intel-v<version>.zip` with one zip per skill under `skills-to-upload/`. Claude Desktop → **Customize** → **Skills** → **+** → **+ Create skill** → **Upload a skill** → each zip. An Owner can turn off **User-created skills**, which removes the upload option. The Plugins page also has an upload option that takes a "plugin package" (`plugin-package/deal-intel-plugin.zip`); its accepted format is not documented precisely. Never run both routes side by side: uninstall one copy first, or two sets of skills with the same names load.

**Either route, then:**

4. Pick a local working folder for Cowork (a trusted folder; Google Drive as a working folder is not documented, though a Drive for Desktop sync folder is just a local folder), open it as the folder Claude works in, and type `/start`. The `start` skill creates `inbox/`, `deals/`, `closed-lost/`, `forecasts/`, `deal-judgment.md` and `templates/forecast-message.md` there, and drops a synthetic sample transcript in `inbox/` so the first test needs no Salesforce. It never overwrites a file that already exists. On the zip route, copying the contents of `workspace-example/` into the folder is the manual equivalent.
5. Fill in `deal-judgment.md` (numbered rules, in your words). Replace `templates/forecast-message.md` with the manager's real format.
6. Connectors: the skills use whatever Salesforce, Slack and Gmail connectors the org admin enabled. If one is missing, the skill says so and stops; it never invents data.
7. Invocation: type `/` in Cowork to list the installed skills, or describe the task in words; Claude matches a skill by its description. Plugins installed through the Claude Code terminal do not appear in Cowork.

## Daily use

- **First run, once** → `/start` in the folder you picked. Creates the workspace and a sample transcript to test on.
- **Assignment email arrives** → `/deal-room new <opportunity name>`. Room created from Salesforce fields.
- **After a call** → `/deal-room sync <opportunity>`. If the Gong activity in Salesforce carries the transcript, it is filed automatically. If it carries only a summary or link, the summary is filed and the skill lists the Gong links; download those transcripts into `inbox/` and run `/deal-room ingest`.
- **Any time** → `/deal-room ask <opportunity> when did they say they'd decide`.
- **Wednesday** → `/forecast`. Pick, review the draft, say "send".
- **Weekly** → `/closed-lost sync` then `triage`; `/closed-lost due` for who to call.


## What is automatic and what is manual (verified 2026-09-17)

| Data | Reaches Claude automatically? | How |
|---|---|---|
| Opportunity fields (stage, MRR, close date, next step, owner) | Yes | Salesforce connector, under the rep's own permissions |
| Per-call AI brief, key points, next steps, outcome, participants, Gong link | Yes, if the org has the Gong for Salesforce package | Gong Conversation records via the Salesforce connector (`/deal-room sync`) |
| Full call transcript | **No.** Gong never writes transcript text into Salesforce, into its emails, into Zapier/Slack payloads, or into its official MCP server | Rep downloads it from the Gong call page into `inbox/` (three clicks), then `/deal-room ingest` |
| Slack post to the manager | Yes | Slack connector, only after "send" |
| Scheduled runs | Cowork scheduled tasks (all paid plans) run in the cloud with connectors and skills; on Enterprise plans an Owner must turn on "Run Cowork in the cloud". A task that writes to a local folder runs only while the machine is on | Forecast draft: cloud. Deal-room sync into a local folder: local, or manual |

Upgrades that need an admin, in order of value: (1) the Gong tech admin registers a Gong MCP integration for Claude, which adds Gong's own `ask_deal` and `generate_brief` inside Claude (still no raw transcripts, and it consumes Gong credits); (2) the Claude org Owner enables cloud Cowork so the Wednesday draft runs unattended; (3) Claude in Chrome enabled with gong.io allowlisted, which lets the rep save a transcript into `inbox/` from the call page without downloading.

## Scheduling (optional)

Cowork scheduled tasks run in Anthropic's cloud on a fixed cadence and can use connectors and the working folder. Two worth creating once the manual versions feel right:
- Wednesday 08:00: "Run /forecast and stop at the candidate table; do not send." Approval mode: manual.
- Daily 07:00: "For every folder in deals/, run /deal-room sync." Approval mode: manual until trusted.

## Safety rules baked into every skill
- Nothing is ever sent (Slack, email) without an explicit "send" in the session.
- Transcripts are never edited; files are moved, never deleted.
- Every fact in notes carries speaker and quote. Every answer cites the file.
- A partial read never produces notes. If a transcript cannot be read to the end, the skill says so.
- No bare probability numbers; assessments cite the rep's numbered rules.

## Testing

`test/run-start.sh` runs `/start` in an empty temp folder through Claude Code non-interactively with the plugin loaded, and asserts the four folders, the two template files byte-for-byte, the sample transcript byte-identical to the fixture, that nothing else was created, and that the closing message names `/deal-room ingest`. `test/check-templates.sh` (also called at the top of `test/run.sh`) fails if the start skill's templates drift from the originals they were copied from.

`test/run.sh` builds a temp workspace from `workspace-example/`, drops the synthetic transcript in `fixtures/inbox/`, runs `/deal-room ingest` through Claude Code non-interactively (Salesforce connector deliberately absent), and asserts the room, notes, brief sections, key facts, verbatim move, and no bare probabilities. `test/run.sh --long` does the same with a ~20k-word transcript to exercise the read-to-the-end rule.

Fixtures are synthetic. No real customer, Gong or Salesforce data is in this repository and none should ever be added.
