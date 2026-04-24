# Sample meeting transcript

Paste this as the **user message** to your system-prompted assistant.

---

**Project: Orion --- Weekly Engineering Sync**
**Date:** 2026-04-22
**Attendees:** Priya (Eng Lead), Marcus (Backend), Jen (Frontend), Dev (QA),
Rohan (PM)

---

**Priya:** OK, let's kick off. Marcus, where are we on the auth rewrite?

**Marcus:** Mostly done. The session token migration is live on staging. I
want to bake it there for another week before we ship to prod.

**Priya:** Another week is fine. So prod by... let's say the 6th of May.

**Marcus:** Works for me.

**Jen:** Can we move the login page redesign to after that? I don't want to
ship two auth changes on the same day.

**Priya:** Yeah, good point. Rohan, can you push the redesign launch by a
week?

**Rohan:** I'll shift it to the 13th. I'll update the roadmap.

**Dev:** Before we go too far --- I still haven't seen the updated test plan
for the auth rewrite. Marcus, was that coming this week?

**Marcus:** Ah, yeah, I'll get that to you. Friday at the latest.

**Dev:** Thanks.

**Jen:** Unrelated, but I saw someone left a `console.log` in the checkout
flow. Whoever it was, please clean that up.

**Marcus:** Hah, that was probably me.

**Jen:** (laughs) I won't name and shame.

**Priya:** OK. Two more things. First --- the licensing question. Rohan, did
legal get back to us on MIT vs Apache-2.0 for the SDK?

**Rohan:** Not yet. I pinged them yesterday. I'll chase today.

**Priya:** Let's not commit to either until we hear back. Second --- the
database migration. I know we talked about doing it this quarter, but given
the auth work I'm starting to think we push it to Q3.

**Marcus:** I'd vote for pushing. We don't have the capacity.

**Jen:** Yeah, same.

**Priya:** OK, let's --- actually, hold on. Let me talk to Amara before we
commit to a delay. I don't want to surprise her.

**Rohan:** Noted. I'll leave the roadmap as-is for now.

**Priya:** Great. Anything else?

**Dev:** Nope.

**Jen:** All good.

**Priya:** Cool, thanks everyone.

---

*(End of transcript.)*
