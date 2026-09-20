# Try it: install, then a 20 minute test

Three Cowork skills: deal room, Wednesday forecast, closed-lost tracker. They run inside your Claude, on the connectors your company already turned on, and write plain files into one folder on your Mac. Everything they write is an ordinary file in that folder: open, edit or delete any of it in Finder, or ask Claude in the chat to show it. Nothing goes to me. If something breaks, tell me what you typed and what it said back. Screenshots of error messages are fine. No customer names or transcripts, please.

## Install (5 min)

1. Claude Desktop > Customize (left sidebar) > Plugins > the Add control (a + or an Add menu, depending on your version) > Add marketplace > Add from a repository. Paste `github.com/oZeppy/deal-intel` and add it.
2. Browse plugins > `deal-intel` > Install. It lands in your personal plugins, saved on your machine, not shared with your company.
3. Make an empty folder for your deals, for example `Documents/Deals`. In Cowork, start a session and give it that folder as the folder Claude works in. It shows under Trusted folders from then on; pick it every time.
4. Type `/start`. It sets the folder up (inbox, deals, closed-lost, forecasts, deal-judgment.md, templates) and drops in a sample transcript to test on. It never overwrites anything you already have.

**Check:** type `/` in the chat. You should see start, deal-room, forecast and closed-lost. If you do not, stop and text me.

No "Add marketplace" option, or the add fails? That is a company setting or a network block on your side. Tell me and I will send the skills as files instead (Customize > Skills > + > + Create skill > Upload a skill, one zip at a time). Use one route only.

Updates: when I text "pushed a fix", go to Customize > Plugins > the marketplace > Update. No files.

Two things to fill in before Test 4, ten minutes total:
- `templates/forecast-message.md`: paste your manager's real format over the sample. The forecast skill will not draft while the word FILL is still in that file.
- `deal-judgment.md`: fill the [FILL] lines in your words. That is where "think like me" lives; the skills cite your rule numbers when they judge a deal. Five lines is plenty to start.

## Test 1: a made-up firm, no Salesforce needed (5 min)

`/start` put a sample transcript in `inbox` (Pinecrest Family Law Group; not a real firm). With the Deals folder open in Cowork, type:

    /deal-room ingest

It will ask what to do about Pinecrest, since your Salesforce does not have it. Pick the option that creates the room now (usually the one marked Recommended). The brief will then mark stage, MRR and close date as pending instead of inventing them. That is what should happen.

What you should see: a `deals/pinecrest-family-law-group` folder with `DEAL.md` and a `.notes.md` file, and the transcript moved out of `inbox`. Two ways to read the brief: in the chat, type `/deal-room show Pinecrest`; or in Finder, open your Deals folder, then `deals`, then `pinecrest-family-law-group`, and double-click `DEAL.md` (if your Mac asks which app, pick TextEdit). The Read section should cite your rules by number, and there should be no "X% chance" anywhere.

Then type:

    /deal-room ask Pinecrest what did they say about their LedgerLaw renewal

You should get a date and a quote with the speaker's name. If it hedges or says "not in the filed calls", tell me.

When you are done, delete the `deals/pinecrest-family-law-group` folder in Finder. It is fake.

## Test 2: one real deal (5 min)

    /deal-room new Riverside Legal Partners - Renewal Q4

Use one of your real opportunities instead of that example, typed the way Salesforce shows it in the Opportunity name, not just the firm's name. It pulls the fields from Salesforce and builds the room. If it says the Salesforce connection is not available, stop and tell me. That is the most important thing I can learn from this test.

    /deal-room sync <the same opportunity>

This looks for Gong call summaries attached to the opportunity in Salesforce. "Found N calls" and "no Gong records" are both useful answers. Tell me which one you got.

## Test 3: one real transcript (3 min)

In Gong, open a call for that deal. More actions > Download transcript. Save the file into your Deals folder's `inbox` (Finder > Deals > inbox). Then:

    /deal-room ingest

It files the transcript under the deal and rewrites the brief. If "Download transcript" is not in the menu, tell me. That is a Gong permission and it changes the plan.

## Test 4: forecast dry run (3 min)

    /forecast

If you have not pasted your manager's format into `templates/forecast-message.md` yet, it stops and asks for it instead of drafting. That is correct, not a bug: paste the format into the chat and it saves it to the file, or skip ahead to Test 5. Otherwise it lists your candidates from Salesforce, asks which to forecast, and drafts the message in your manager's format. Stop there. Nothing goes to Slack unless you type "send" by itself after seeing the draft.

## Test 5: closed lost (2 to 5 min, more if your list is long)

    /closed-lost sync

It says how many closed-lost deals it pulled in, or names the exact Salesforce problem. "0 new" is a normal answer if nothing closed lost recently.

    /closed-lost triage

It walks your list one deal at a time and asks priority, nurture, or reject. Do two or three, then type `stop for now`. Everything you already answered stays.

## Then text me

What worked, what did not, and what it said when it failed. I fix by editing the skill text and pushing it; you click Update on the marketplace. I never need your data.
