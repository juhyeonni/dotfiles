# Skeletons per artifact

Rule shared by every format: **conclusion on the first line, the ask (owner + deadline) on the last.**

## Default length

Used when the user did not specify a length. Declare this value in step 3 and check it in step 5.

| Artifact | Default length |
|---|---|
| Chat / Slack | 5 lines of body + 1 line of ask |
| GitHub issue | 30 lines |
| PR description | 20 lines |
| Email | 12 lines |
| Doc section | 25 lines |
| Paper abstract | 250 words |

- Code blocks, logs and tables do not count toward the line budget. Count prose only.
- If it is about to overflow, do not raise the budget — **cut evidence and out-of-scope material first.** Protect the conclusion and the ask to the last.
- A length the user stated beats this table.

---

## 1. Chat / Slack message

The format that fails most often. The reader is someone skimming past in a thread.

```
[One-line conclusion — what happened and what is needed]

- 상황: (facts, 1–2 lines)
- 영향: (who is blocked and how badly, with numbers if possible)
- 필요: @who, what, by when

(details in thread / link)
```

Rules

- **One-line summary at the very top.** Give the reader what they need to decide whether to stop scrolling.
- Push details into the thread. Do not paste a whole log into the message body.
- A proposal plus an objection window ("A로 가겠습니다. 이견 있으면 오늘 중 알려주세요") closes far faster than an open question ("혹시 이거 어떻게 하는 게 좋을까요?").
- Do not open with an emoji or a greeting. Open with the conclusion.

Before / After

> ✗ 안녕하세요! 어제 배포 관련해서 여쭤볼 게 있는데요, 혹시 스테이징에서 결제 쪽 테스트 돌려보신 분 계실까요? 저희 쪽에서 확인해보니 좀 이상한 부분이 있어서요…
>
> ✓ **스테이징 결제 API가 어제 배포(#412) 이후 500을 반환합니다. 프로덕션 배포를 보류해 주세요.**
> - 상황: `POST /payments` 응답 500, 재현율 10/10
> - 영향: 스테이징 QA 전면 중단
> - 필요: @박 원인 확인 후 오늘 15시까지 회신 / @팀 프로덕션 배포 홀드

---

## 2. GitHub issue

The reader is **someone in the future**. A person with none of today's context must be able to pick it up from this alone.

```
Title: [area] observed symptom (not the cause)

## 요약
One paragraph. What went wrong, how, and why it matters.

## 재현 절차
1.
2.
3.

## 기대 동작 / 실제 동작
- 기대:
- 실제:

## 환경
Version / OS / branch or commit

## 근거
Logs, stack traces, failing tests, screenshots

## 범위 밖
(What this issue will not cover — keeps the discussion from leaking)
```

Rules

- **Write the title as a symptom.** "인증 리팩터링 필요" ✗ / "토큰 만료 후 재로그인하면 401이 반복됨" ✓. The cause is still a hypothesis.
- Without repro steps it is a note, not an issue. If there are none, say "재현 미확보".
- Do not mix speculation with observation. Separate speculation under `추정 원인:`.
- Put logs inside a `<details>` fold.

---

## 3. Pull request description

The reader is **the reviewer**. What they want is not "what changed" but **"why it changed, and where should I look hardest"**. The diff is already visible.

```
## 왜
The problem being solved. Link the issue. (Fixes #123)

## 무엇을
The core of the change in 1–3 lines. No file listings.

## 어떻게 확인했나
- [ ] Unit tests added/updated
- [ ] Manual verification steps:
- Screenshots / before-after (if UI)

## 리뷰 포인트
Where you want focused attention and why. Which alternatives were dropped and why.

## 위험 / 롤백
Blast radius, whether there is a migration, how to revert.
```

Rules

- A PR with no "why" gets reviewed slowly. Do not substitute an issue link for it; write at least one line.
- **Never paste the commit list.**
- Disclose the weaknesses you already know about ("이 부분은 임시 방편입니다, 후속 #124"). Letting the reviewer discover them costs trust.
- If it is big, split it. A description that keeps growing usually means the PR is too large.

---

## 4. Email / external communication

```
Subject: [action] what, by when — be specific

First paragraph: conclusion + ask (2–3 sentences)
Middle: only the evidence that is needed
Last: next action, deadline, where to reply
```

- No bare "안내", "공유", "문의" in the subject. Put the content in: "9/15 점검으로 03–05시 API 중단".
- Keep apologies and pleasantries to one line at most.
- If the other side has to decide, **hand them organized options.** An open question gets a slow reply.

---

## 5. Design doc / RFC

```
1. Problem (why now)
2. Goals / non-goals
3. Proposal
4. Alternatives considered and why they were dropped   ← the most important one
5. Risks and open questions
6. Rollout plan
```

- Always write the **non-goals.** Nothing prevents scope leak better.
- An empty "alternatives considered" reads to the audience as no consideration at all.

---

## 6. Paper / academic manuscript

Following Mensh & Kording.

- **Abstract**: carry Context → Content → Conclusion in full. Most readers read only this.
- **Introduction**: narrow from field → subfield → the gap this work fills. It is a **gap argument**, not a literature list. Put this paper's contribution in the last paragraph.
- **Results**: each paragraph is one "question → data → answer" cycle.
- **Discussion**: how the gap was filled → limitations → what it means for the field.
- Spend your time on the title, abstract, figures and outline. They are read overwhelmingly more than anything else.
- Write the abstract and introduction for a **reader in an adjacent field** (Nature: "accessible to readers in other disciplines").

---

## 7. Code review comments

- Point at the code, not the person: "왜 이렇게 하셨어요?" ✗ / "이 경로에서 `nil`이면 패닉이 납니다" ✓
- Mark **blocking / suggestion / taste** distinctly: `blocking:` / `suggestion:` / `nit:`
- Do not just name the problem, give a direction. If you have no direction, say it is a question.
- Leave one line on what was done well, too.
