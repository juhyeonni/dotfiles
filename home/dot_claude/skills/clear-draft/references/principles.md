# Clarity and readability principles, with sources

Only rules that were empirically validated at the sentence level, or codified by an authoritative body.

---

## A. Structure — the order of reading is the order of understanding

### A1. Conclusion first (BLUF / 重点先行)

Japan's Agency for Cultural Affairs, 「公用文作成の考え方」 (文化審議会 建議, 2022), Ⅲ-4:

> 「結論は早めに示し、続けて理由や詳細を説明する。」

A reader can stop at any moment. If the conclusion is at the end, anyone who stopped received nothing.

### A2. C-C-C (Context → Content → Conclusion)

Mensh & Kording, "Ten simple rules for structuring papers", *PLOS Comput Biol* (2017), Rule 3. Apply the same pattern at every level — the whole paper, each section, each paragraph. For a paragraph: first sentence is the topic, the middle carries new information, the last is the message to leave behind.

### A3. No zigzagging

Same paper, Rule 4. Cover one topic once, and refer to a given concept with **the same word** every time. Swap in a synonym and the reader has to compute whether you meant something different.

### A4. Headings alone should convey the whole

文化庁 Ⅲ-2:

> 「見出しを追えば全体の内容がつかめるようにする。」

In GitHub issues, PRs and docs, subheadings and bold text play this role.

---

## B. Sentences — Gopen & Swan's seven reader-expectation principles

George Gopen & Judith Swan, "The Science of Scientific Writing", *American Scientist* 78 (1990). The standard treatment of the English academic sentence.

1. Follow a grammatical subject **with its verb as soon as possible** — "Follow a grammatical subject as soon as possible with its verb."
2. **The stress position is the end of the sentence.** Put the new information you want remembered there.
3. **The topic position is the front.** Say up front whose or what's story this sentence is.
4. Put **old information** at the front to link back to the previous sentence.
5. Put **the action of a clause in its verb.**
6. Provide **context before** asking the reader to take on something new.
7. Match the emphasis created by structure to the weight of the content.

The paper's conclusion:

> "The structure of the prose becomes the structure of the scientific argument."

**The practical rule that matters most**: build every sentence as `[what is already known] → [what is new]`. Holding that one rule alone makes a paragraph cohere.

---

## C. Sentences — 文化庁 「公用文作成の考え方」 Ⅲ-3 (original text)

The Japanese government's official writing standard. It transfers to Korean almost unchanged.

| | Original | Applied to Korean |
|---|---|---|
| ア | 一文を短くする。 | 한 문장을 짧게 |
| イ | 一文の論点は、一つにする。 | 한 문장 한 논점 |
| ウ | 三つ以上の情報を並べるときには、箇条書を利用する。 | 3개 이상 나열은 불릿으로 |
| エ | 基本的な語順を踏まえて書く。 | 언제·어디서·누가·무엇을·어떻게 |
| オ | 主語と述語の関係が分かるようにする。 | 주어–서술어 호응 |
| カ | 接続助詞や中止法を多用しない。 | "~하고, ~하며, ~하여" 연결 남발 금지 |
| キ | 同じ助詞を連続して使わない。 | "~의 ~의", "~에 ~에" 금지 |
| ク | 複数の修飾節が述部に掛かるときには、長いものから示すか、できれば文を分ける。 | **긴 수식어를 앞에** |
| ケ | 受身形をむやみに使わない。 | 피동 남용 금지 |
| コ | 二重否定はどうしても必要なとき以外には使わない。 | 이중부정 금지 |
| サ | 係る語とそれを受ける語、指示語と指示される語は近くに置く。 | 수식어–피수식어, 지시어–대상을 가까이 |
| シ | 言葉の係り方によって複数の意味に取れることがないようにする。 | 중의성 제거 |
| ス | 読点の付け方によって意味が変わる場合があることに注意する。 | 쉼표 위치가 뜻을 바꾼다 |

On register: 「一つの文・文書内では、常体と敬体のどちらかで統一する。」 — do not mix registers within one document.

---

## D. A Korean-specific problem — translationese

한재영, 「한국과학교육학회지 논문의 글쓰기 사례 연구」, 『한국과학교육학회지』 35(4), 649–663 (2015). An analysis of nine papers in a KCI-indexed journal, yielding this list of **high-frequency problem cases** (from the original abstract):

> 빈도가 높은 문제사례는 '~적', '영어 사용', '복수 표현', '하다류 피동', '~고 있는', '~을 통하여', '~에 대하여', '가지다', '관형격조사 ~의', '사물주어 수동태', '사동(시키다)' 등이었다.

How to correct them:

| Problem | Before | After |
|---|---|---|
| `가지다` (literal "have") | 59.2%의 설명력을 **가지는** 것으로 나타났다 | 59.2%를 설명했다 |
| `~을 통하여` | 본 연구결과를 **통해** … 필요하다 | 이 결과는 …가 필요함을 보여준다 |
| `~에 대하여` | X에 대한 분석을 수행하였다 | X를 분석했다 |
| `하다`-type passive | 분석이 수행**되었다** | (연구진이) 분석했다 |
| Inanimate-subject passive | 결과가 도출**되어졌다** | 결과를 얻었다 |
| Chained genitive `~의` | 사용자**의** 데이터**의** 처리**의** 지연 | 사용자 데이터를 처리할 때 생기는 지연 |
| Overused `~적` | 융복합**적** 영향을 파악하고자 | 어떻게 영향을 주는지 확인하려고 |
| `~고 있는` | 증가하**고 있는** 추세를 보이고 있다 | 늘고 있다 |
| Causative `시키다` | 자아존중감을 증진**시키려는** | 자아존중감을 높이려는 |

Also common: `~에 의해`, `되어지다` (double passive), overused `~것이다`, `~에 있어서` (a literal rendering of Japanese 「において」). These are not named in that abstract, so treat them as received wisdom only.

---

## E. Vocabulary — what actually hurts readability is not technical terminology

Plavén-Sigray et al., "The readability of scientific texts is decreasing over time", *eLife* 6:e27725 (2017). An analysis of **709,577 abstracts across 123 journals**, 1881–2015.

- Flesch Reading Ease correlates with year at **r = −0.93**, New Dale-Chall at **r = 0.93** — monotonic decline over 130 years.
- Share of abstracts below FRE 0 (hard even for college graduates): **14% in 1960 → 22% in 2015**.
- The component that grew most strongly was not field-specific terminology but **general scientific jargon** (r = 0.96). The authors' list of these "academic clichés" alone runs to **2,138 entries**.
- **Sentence length has also risen continuously** since 1960.

> "this trend is indicative of a growing use of general scientific jargon"

In other words the culprits are **field-agnostic academic idioms** — `robust`, `elucidate`, `underscore`, `novel`, `paradigm`, or "유의미한 시사점을 제공한다", "고찰이 요구된다". Use technical terms when they are needed; delete the clichés.

---

## F. Hedging — overdo it and both comprehension and confidence fall

Ryba et al., *Frontiers in Psychology* 12:714321 (2021). An experiment manipulating nine stylistic components of an abstract (setting, narrator, punctuation, conjunctions, signposts, noun chunks, acronyms, **hedges**, total word count).

| Measure | Traditional style | Accessible style |
|---|---|---|
| Readability | 44.4% | **66.3%** |
| Comprehension | 47.9% | **57.9%** |
| Confidence | 44.1% | **58.3%** |

- Manipulation range: hedges **0 (easy) ↔ 4 (hard)**, runs of 3+ consecutive nouns **0 ↔ 6**, total length **110 ↔ 230 words**.
- Conclusion: "hedging only where necessary can help emphasize the message", "breaking up noun chunks can help the reader digest ideas".

**Where a hedge belongs**: the sample is small, causality was not established, the result changes under different conditions.
**Where it does not**: you simply lack confidence.

---

## G. Explicit rules from journals and editorial bodies

**Nature Portfolio** (How to write your paper):

> "Using the active voice ('we performed the experiment...') typically helps readers better understand concepts and results described in a paper."
> "Write clear and direct sentences."

**Nature** (formatting guide):

> "Contributions should therefore be written clearly and simply so that they are accessible to readers in other disciplines"
> "technical jargon should be avoided as far as possible and clearly explained where its use is unavoidable"

**EASE Guidelines** (European Association of Science Editors):

> "Sentences generally should not be very long."
> "Do not overuse passive constructions." — recommended `X was measured…` / discouraged `Measurements of X were carried out…`
> "Avoid colloquial and idiomatic expressions, as well as phrasal verbs … which are often difficult to understand by non-native speakers of English."

**PLOS ONE**:

> "Do not use non-standard abbreviations unless they appear at least three times in the text."
> "authors should avoid overstating their conclusions"

**US digital.gov (Plain Language)** — on nominalization:

> "A hidden verb (or nominalization) is a verb converted into a noun. It often needs an extra verb to make sense." (suffixes `-ment, -tion, -sion, -ance`, dragging along filler verbs like `achieve, effect, give, have, make, reach, take`)

---

## H. Reference numbers

- Sentence length in Korean and Japanese papers: across 60 humanities journal articles, **around 70 characters per sentence** was observed as the threshold at which writers start reaching for a comma (岩崎·井伊, 『専門日本語教育研究』 26, 2024).
- Clear style is an impact variable, not a taste: more narrative abstracts get cited more (Hillier et al., *PLOS ONE* 11:e0167983, 2016; 732 abstracts, narrativity ↔ log citations R² = 0.05, p = 10⁻⁹).

---

## Sources

- Gopen & Swan (1990), *American Scientist* 78 — https://cseweb.ucsd.edu/~swanson/papers/science-of-writing.pdf
- Mensh & Kording (2017), *PLOS Comput Biol* — https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1005619
- Plavén-Sigray et al. (2017), *eLife* 6:e27725 — https://elifesciences.org/articles/27725
- Ryba et al. (2021), *Front. Psychol.* 12:714321 — https://www.frontiersin.org/articles/10.3389/fpsyg.2021.714321/full
- Hillier et al. (2016), *PLOS ONE* 11:e0167983 — https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0167983
- 文化庁「公用文作成の考え方」(2022) — https://www.bunka.go.jp/seisaku/bunkashingikai/kokugo/hokoku/pdf/93651301_01.pdf
- 한재영 (2015), 『한국과학교육학회지』 35(4) — https://www.koreascience.kr/article/JAKO201528551642177.page
- Nature Portfolio — https://www.nature.com/nature-portfolio/for-authors/write
- Nature formatting guide — https://www.nature.com/nature/for-authors/formatting-guide
- EASE Guidelines — https://www.ease.org.uk/wp-content/uploads/2018/11/doi.10.20316.ESE_.2018.44.e1.pdf
- PLOS ONE submission guidelines — https://journals.plos.org/plosone/s/submission-guidelines
- digital.gov Plain Language — https://digital.gov/guides/plain-language/writing/
