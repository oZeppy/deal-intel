# {{Opportunity name}}

Account: {{Account}}
Stage: {{Stage}}
Forecast: {{Forecast category}}
MRR: {{MRR}}
Close date: {{Close date}}
Next step: {{Next step}}
Owner: {{Owner}}
Created: {{Created date}}
Source: {{Lead source}}
Salesforce: {{Record URL}}
Salesforce fields refreshed: {{refreshed date}}

One field per line, label then value. Show a field only when it has a value; drop the line entirely when it does not. When any Salesforce field is missing, print one line in place of the missing ones instead of scattering markers through the file:

**Still needed from Salesforce:** Stage, Forecast, Close date, Created, record link. Run `/deal-room refresh <opportunity>` once the Salesforce connection is on, or paste the fields here and I will fill them in.

## Summary
- **Who they are:** {{one line, 20 words or fewer}}
- **Why they are looking:** {{one line, 20 words or fewer}}
- **Where it stands:** {{one line, 20 words or fewer}}
- **What happens next:** {{one line, 20 words or fewer}}
- **What could kill it:** {{one line, 20 words or fewer}}

One line per bullet, never a paragraph. If a bullet does not fit on one line, cut detail, do not wrap.

## Read
First line, exactly this shape: **Read: <real / not real yet>. Forecast: <category>.**
Second line: **Next: <one action, owner, date>.** Take it from the Commitments row with the earliest Due date.
Third line: **Overdue: <item and how late>** or, when nothing is late, **Overdue: none**. Work it out by comparing each Commitments Due date to today.
Then apply `deal-judgment.md` rule by rule. Name each rule used. No bare probability numbers. Close with the single fact that would change the read.

## Firm facts
Attorneys · staff · practice areas · offices · current software · billing model · anything else stated. Each fact: (date, speaker, quote).

## Timeline and triggers
What they said about when and why. Mark superseded statements ("was Q4, now Q1 per 2026-09-10").

## Stakeholders
Name · role · stance · what they care about · (date, quote).

## Objections and risks
Each: the concern, who raised it, what was said in response, status.

## Competitors
Named · what the prospect said · our angle.

## Commitments and next steps
Sorted by Due date, soonest or most overdue first. The Status cell is exactly one of: `done`, `due <date>`, `OVERDUE <n> days`, `waiting on <name>`. Never free text.

| Date | Who | What | Due | Status |
|---|---|---|---|---|

## Call log
| Date | Title | Participants | Length | Notes file | Full transcript? |
|---|---|---|---|---|---|

## Open questions
Things we still need to learn, each with who could answer it.
