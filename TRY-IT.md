# Try it: install, then a 20 minute test

Three Cowork skills: deal room, Wednesday forecast, closed-lost tracker. They run inside your Claude, on the connectors your company already turned on, and write plain files into one folder on your Mac. Nothing goes to me. If something breaks, tell me what you typed and what it said back. Screenshots of error messages are fine. No customer names or transcripts, please.

## Install (5 min)

1. Claude Desktop > Customize (left sidebar) > Plugins. Find the Add control (a + or an Add menu, depending on your version) > Add marketplace > Add from a repository. Paste `github.com/oZeppy/deal-intel` and add it.
2. Browse plugins > `deal-intel` > Install. It lands in your personal plugins, saved on your machine, not shared with your company.
   No "Add marketplace" option, or the add fails? That is a company setting or a network block on your side. Tell me. Fallback: the starter zip I emailed has three skill zips under `skills-to-upload`; Claude Desktop > Customize > Skills > + > + Create skill > Upload a skill, one zip at a time. Use one route only. If you ever switch, uninstall the other copy first, or the skills load twice.
3. Updates: when I text "pushed a fix", go to Customize > Plugins > the marketplace > Update. No files.
4. From the starter zip, make a folder for your deals, for example `Documents/Deals`, and copy everything inside `workspace-example` into it. You get `inbox`, `deals`, `closed-lost`, `forecasts`, `deal-judgment.md` and `templates`.
5. In Cowork, start a session and give it the `Deals` folder as the folder Claude works in. After the first time it shows under Trusted folders. Pick it every time. Typing `/` in the chat lists the three skills.
6. Optional now, needed by Wednesday: open `templates/forecast-message.md` and paste your manager's real format over the placeholder. The forecast skill will not draft until that is done.
7. Optional now, worth 10 minutes soon: open `deal-judgment.md` and fill the [FILL] lines in your words. That is where "think like me" lives. The skills cite the rule numbers when they judge a deal.

## Test 1: a made-up firm, no Salesforce needed (5 min)

There is a sample transcript already in `inbox` (Pinecrest Family Law Group; not a real firm). In Cowork, with the Deals folder open, type:

    /deal-room ingest

It will ask which deal the file belongs to, because Pinecrest is not in your Salesforce. Reply:

    Pinecrest is made up and not in Salesforce. Create the room with these fields: Stage 3 - Discovery, MRR 9120, close date 2026-12-15, next step "Pricing and migration plan by Sep 17, demo Sep 24".

What you should see: a `deals/pinecrest-family-law-group` folder with `DEAL.md` and a `.notes.md` file, and the transcript moved out of `inbox`. Open `DEAL.md`. The Read section should cite your rules by number, and there should be no "X% chance" anywhere.

Then type:

    /deal-room ask Pinecrest what did they say about their LedgerLaw renewal

You should get a date and a quote with the speaker's name. If it hedges or says "not in the filed calls", tell me.

When you are done, delete the `deals/pinecrest-family-law-group` folder. It is fake.

## Test 2: one real deal (5 min)

    /deal-room new <one real opportunity name>

It pulls the fields from Salesforce and builds the room. If it says the Salesforce connector is not available, stop and tell me. That is the most important thing I can learn from this test.

    /deal-room sync <same opportunity>

This looks for Gong call summaries attached to the opportunity in Salesforce. "Found N calls" and "no Gong records" are both useful answers. Tell me which one you got.

## Test 3: one real transcript (3 min)

In Gong, open a call for that deal. More actions > Download transcript. Save the file into your `inbox` folder. Then:

    /deal-room ingest

It files the transcript under the deal and rewrites the brief. If "Download transcript" is not in the menu, tell me. That is a Gong permission and it changes the plan.

## Test 4: forecast dry run (3 min)

    /forecast

It lists your candidates from Salesforce, asks which to forecast, and drafts the message in your manager's format. Stop there. Nothing goes to Slack unless you type "send".

## Test 5: closed lost (2 min)

    /closed-lost sync

then

    /closed-lost triage

Every run ends with one status line. If Salesforce fails, the line says exactly what failed instead of going quiet.

## Then text me

What worked, what did not, and what it said when it failed. I fix by editing the skill text and send you a new zip. I never need your data.
