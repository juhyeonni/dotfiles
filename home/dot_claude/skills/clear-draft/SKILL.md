---
name: clear-draft
description: Ask for the missing inputs first, then write the draft. Use whenever the user wants to write something that must land clearly with a reader — a Slack/chat message, a GitHub issue, a PR description, a design doc, an email, a bug report, a paper paragraph, a review comment, a proposal, an announcement. Also use when the user says their writing is unclear, too long, rambling, "정리해줘", "명확하게 써줘", "이거 어떻게 전달하지", or when they hand over rough notes and expect a finished message. Do NOT use for pure code generation or for questions the user only wants answered conversationally.
---

# clear-draft

Communication usually fails for lack of **inputs**, not for lack of prose skill. What lives only in the writer's head — purpose, audience, conclusion, evidence, the ask — never makes it onto the page.

So this skill inverts the order. **Ask first, write second.** The questions gather information and organize the user's own thinking at the same time.

## Absolute rules

1. **Questions come before the draft.** Except for anything already answerable from the material.
2. **Ask with the AskUserQuestion tool.** Do not list questions in the body text.
3. **Question budget: at most 4 per round, at most 2 rounds.** Beyond that the user tires. Fill remaining blanks with estimates and mark them in the draft as `[가정: ...]`.
4. **Always put the recommended option first and label it `(추천)`.** The user should only have to pick.
5. **Under unattended execution (scheduler, background), do not ask** — fill every slot by estimation and state the assumptions at the top. Keep that **assumption block to 3 lines or fewer** and list only what is costly to get wrong. Fold the rest into the body.

## Step 1 — Slot diagnosis (internal; never printed)

Read the material the user provided (message, pasted logs, files, conversation context) and fill in these seven slots.

| Slot | What it asks | What goes wrong when empty |
|---|---|---|
| **1. Artifact** | Where does this get posted (chat / GH issue / PR / email / doc / paper) | Format, length and tone are all off |
| **2. Outcome** | What do you want the reader **to do** | The reader finishes and thinks "so what?" |
| **3. Audience** | Who they are, what they already know, how they currently understand this issue | Over- or under-explaining |
| **4. One-sentence core** | If only one line survived, which one | The conclusion gets buried at the end |
| **5. Evidence** | Why you can claim this (numbers, logs, repro steps, precedent) | Assertion without persuasion |
| **6. Ask** | What the reader must do, and by when | Nobody moves |
| **7. Constraints** | Length, tone, language, forbidden wording, who may see it | It gets rewritten |

**How to fill them**

- Clearly readable from the material → **fill it in, do not ask.**
- Inferable but costly if wrong (especially 2, 3, 6) → **ask.**
- Obvious by convention (the format of a PR description, say) → **fill it in and note it in one line in the draft.**

## Step 2 — Questions

Ask at most 4, ordered by **how costly each blank is to get wrong**. Priority: `2. Outcome` > `3. Audience` > `6. Ask` > `4. Core` > `5. Evidence` > `7. Constraints` > `1. Artifact`.

Rules for writing the questions:

- One slot per question.
- Options must be **mutually exclusive real scenarios**. No graduated scales like "detailed / normal / brief". Split by **audience and use** instead: "3줄 요약(스레드에서 훑는 사람용)" vs "재현 절차 포함(직접 고칠 사람용)".
- Each option's description says in one line **how that choice changes the output**.
- Never ask back something the user already said.

Example questions (given a request to write a GitHub issue):

- `[처리 방향]` 이 이슈로 누가 무엇을 하길 원하세요? → "본인이 고칠 것, 기록만 남김(추천)" / "다른 팀이 고쳐야 함" / "고칠지 말지 논의부터"
- `[독자]` 읽는 사람이 이 코드를 아나요? → "같은 모듈 담당자" / "다른 팀, 맥락 모름" / "외부 오픈소스 사용자"
- `[근거]` 재현 자료 중 가진 것은? (복수 선택) → 에러 로그 / 재현 절차 / 실패 테스트 / 스크린샷 / 없음

## Step 3 — Lock the one-liner

Before drafting, show the user the **core sentence (BLUF) and the length** in one line, then proceed.

> 확정: **"X 때문에 Y가 발생하니, Z를 이번 주 안에 해달라."** — 이 방향으로, GitHub Issue 30줄 이내로 씁니다.

Do not ask about length. It follows from the artifact, so it is not worth question budget. Take the default from `references/formats.md` and **just declare it** — the user can correct it in one word if it is wrong.

If that one line cannot be written, the user does not know yet either. In that case, point at that gap instead of producing a draft.

## Step 4 — Writing

Structure is **C-C-C (Context → Content → Conclusion)**, ordered **conclusion first**. Per-artifact skeletons and sentence rules live in the reference files.

- Artifact templates (chat / GH issue / PR / email / doc / paper) → `references/formats.md`
- Sentence and paragraph principles, with sources → `references/principles.md`
- Real exemplar papers and Before/After passages (Korean, English, Japanese) → `references/examples.md`

Four things to hold throughout:

1. **Conclusion in the first sentence.** Background goes after it.
2. **One point per paragraph.** The paragraph's first sentence is its topic sentence.
3. **Actions belong in verbs.** "검토를 진행하였다" → "검토했다". Break up noun chains like "~의 ~의 ~에 대한".
4. **Say you do not know when you do not, and state plainly what you do.** Hedges (가능성 있음, ~로 보임) belong only where the uncertainty is real.

## Step 5 — Self-check (required before handing over)

Once the draft is done, actually walk this list, fix only what it catches, then send.

- [ ] Do the first 3 lines alone tell the reader **what happened and what they must do**
- [ ] Does the ask name **an owner and a deadline** ("확인 부탁드립니다" ✗ / "@김 이번 주 목까지 승인 여부만" ✓)
- [ ] Does any single sentence carry two points (in Korean and Japanese, consider splitting past **roughly 70 characters**)
- [ ] Is the same concept always called by the same word (no synonym-swapping)
- [ ] Is it clear within the sentence what "이것/그것/해당" refers to
- [ ] Was each abbreviation expanded on first use
- [ ] Any assertion without evidence, or any hedge attached to something you do have evidence for
- [ ] Any sentence whose deletion would not change the meaning → delete it
- [ ] **Did it stay within the length declared in step 3** → if not, cut evidence and out-of-scope material first. Protect the conclusion and the ask to the last
- [ ] If a `[가정: ...]` marker is still there, has the user confirmed it

## Wrap-up

Alongside the draft, state **in one line** what was assumed and what the user needs to verify. Do not re-explain the draft.
