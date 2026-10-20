# Sources: references resolved, citations by canon, texts by name

A design sketch, before code. Status: `phil/canon` is built, by rule,
over a table of works built from PerseusDL (`lib/phil/canon`,
`bench/tools/canon.py`): every Plato dialogue and the seven works of
Aristotle in canonical-greekLit; Aristotle's logical works, *Physics* and
*De Anima* are not there and wait for Open Greek and Latin. The rest is
proposed. What
ϕwb does not yet do, and what the rest of the field does worst: say
whether a reference is on record, whether a canonical citation names a
passage that exists, and whether a quotation matches its edition. This
is the layer `claims/attributed-unread` points at when it says "which
work would let it", and the one the bench's `pairs` want when a
commentary cites its source by Bekker page.

## Why

Three findings from the sweep of October 2026 decide the design.

1. **Fabricated references are the best-measured harm of models in
   scholarship.** Biomedical papers with at least one fabricated
   reference went from 1 in 2,828 (2023) to 1 in 277 (early 2026); the
   one humanities study found most DOIs hallucinated even where the
   works existed; an ethics journal retracted a paper in May 2026 whose
   author had let a model "identify and understand" its sources.
2. **The open checkers fail in the direction a philosopher cannot
   afford.** Five of them detect 60 to 100 per cent of fabricated
   references and accept only 26 to 69 per cent of real ones, because a
   1978 monograph with no DOI is "not found" to an index built for
   STEM. None checks PhilPapers, WorldCat or a library catalogue.
3. **Rules first keeps the false alarms down.** The HALLMARK benchmark
   (2,526 entries, 14 kinds of fabrication) found that agentic lookups
   buy recall at the cost of false positives, and that a cascade
   beginning with a rule-based verifier avoids the inflation. That is
   "the model proposes, the rules decide" as an empirical result.

So: a deterministic resolver, with *not indexed* kept apart from
*fabricated* in its vocabulary and its exit status, the sources a
philosopher's references actually live in, and a model used, if at
all, only to parse a messy free-text reference into fields.

## What stays in wwb, what is ϕwb's

wwb's `claims`, `bib` and `facts` stay where they are: a reference with
an impossible DOI, a citation dated in the future, a name one letter
from the bibliography's, a document that disagrees with itself. Those
are a writer's checks and need no network.

What is ϕwb's is what needs the world: resolving a reference against
the record, resolving a canonical citation to a passage, comparing a
quotation to an edition. The sources are a philosopher's (PhilPapers,
Perseus, a library catalogue), and the findings feed the corpus
(`claims/attributed-unread` resolved, a commentary's citation of its
source checked).

## The name space, sketched

As NAMESPACE-LAYOUT asks: `/n` for trees imported whole under their
authors' schema, `/mnt` for trees a program here synthesizes.

```
/n/perseus/                  PerseusDL canonical-greekLit, First1KGreek:
                             TEI as cloned, laid out by CTS URN (CC BY-SA 4.0)
/n/gutenberg/                the ebooks the bench is built from, as fetched

/mnt/sources/                phil/sourcefs
    lookup                   write one reference (a BibTeX entry or a line
                             of text); read back verdict lines on the same fid
    src/                     one directory a source, each a mount made by the
                             operator, each a webfs-style ctl/query/result tree:
      crossref/ openalex/ opencitations/     DOIs, metadata, retractions
      openlibrary/ hathitrust/ loc/           monographs with no DOI, key-free
      philpapers/                             per user, per their terms, never cached past a session
    cache/                   what was asked and answered, one file each, a session's
    status                   sources up, requests made, rate limits left

/mnt/canon/                  phil/canonfs over /n/perseus and a works table
    urn:cts:greekLit:tlg0059.tlg030/514a        Republic 514a, Greek
    urn:cts:greekLit:tlg0059.tlg030/514a.en     the public-domain English beside it
    kant/aa/03/075                              Akademie-Ausgabe volume 3, page 75
```

A reader never sees `/mnt/sources`. The driver, the tools and the
person do. `src/*` and `cache/` are not in any agent's name space; an
agent that resolves a reference writes to `lookup` and reads its
verdict, and that is all it can do.

## The verdicts

In the workbench's idiom, one line each, `file:line: rule: message`.

`phil/cite` reads references (a BibTeX file; the lines wwb's `claims`
found wanting; a corpus's `works`) and writes:

| Rule | Meaning |
|---|---|
| `cite/found` | resolved; which source, and the record's identifier |
| `cite/doi-mismatch` | the DOI resolves to another work; what it is |
| `cite/year-differs`, `cite/author-differs`, `cite/title-differs` | found, with one field wrong; the source's value |
| `cite/retracted` | found, and marked retracted (Retraction Watch's data is in Crossref) |
| `cite/not-indexed` | no source answered; the sources asked. Not a finding of fabrication |
| `cite/fabricated` | a DOI that resolves to nothing, or a journal, volume and page the journal's own record says never existed |
| `cite/unparsed` | the reference could not be read into fields; what was tried |

The cascade is fixed: an identifier first (DOI, ISBN, arXiv, PhilPapers
id); then title, author and year against each source in
`lib/phil/sources`' order, with thresholds stated there; a monograph
with no DOI goes to Open Library, the Library of Congress and HathiTrust
before anything says `not-indexed`. A model is asked, if at all, only to
turn free text into fields, and its parse is `cite/unparsed` unless
every field it names is in the text (`vet`'s rule, for citations).

`phil/canon` reads canonical references in prose and notes (*Republic*
514a, *Met.* 1003a21, KrV A 51/B 75, DK 22 B 30) from a table in
`lib/phil/canon` and writes `canon/resolved` with the URN or edition
page, `canon/unknown` for an abbreviation the table lacks, and
`canon/no-such-passage` for a page or line the work does not have. With
`/mnt/canon` mounted, `phil/quote` compares a quotation to the edition
and writes `quote/differs` with the edition's words.

For the corpus: `claims/attributed-unread` names a work; `phil/cite`
on the `works` line says whether that work is on record, and
`phil/canon` on the reporting sentence says which passage it cites, so
the corpus owner knows what to read in to let the check run.

## What is on the shelf, and what is not

- **Key-free sources.** Open Library (1 request a second, 3 with a
  User-Agent and an address; bulk only by monthly dump), loc.gov's
  JSON, HathiTrust's bibliographic API by identifier, OpenCitations
  (CC0, REST and dumps), Crossref (back off on 429; the annual public
  file for bulk). WorldCat's v1 API was retired at the end of 2024 and
  v2 needs an OCLC subscription: not a source here.
- **PhilPapers.** Its API terms forbid redistribution and allow a
  user's queries; a per-user mount, uncached past a session. The terms
  are read before any code touches it.
- **Canonical citations.** The Classical Works Knowledge Base resolver
  has been offline since 2024. hucitlib (Romanello) carries author and
  work abbreviations, CTS URNs and citation structures for the
  classical canon and is the table to start from. No open parser for
  Bekker, Stephanus or Akademie-Ausgabe references was found; the one
  here would be the first, and small.
- **Texts.** PerseusDL and Open Greek and Latin are CC BY-SA TEI in
  git, already laid out by URN: a clone is a mount. Scaife, the
  viewer, is not needed. The Bonner Kant-Korpus serves one HTML page
  per Akademie page with no XML and no stated licence: citable, not
  bindable. The DTS 1.0 API (February 2026) is a thin shim to add
  outward later, so DH tools can read `/mnt/canon`; nothing here needs
  it.

## Literature discovery

Not built, and not to be built as search. Every mainstream tool sits on
Semantic Scholar or OpenAlex and none sees PhilPapers; general
deep-research agents cannot read JSTOR and hallucinated 3.5 to 13.3 per
cent of their URLs in the April 2026 measurement, worst in theology and
classics. The one philosophy-native tool, PhilLit (Himmelreich and
Meyer, February 2026, open source), is right because of its source
list: PhilPapers, SEP, IEP, NDPR, OpenAlex, CORE, arXiv, every citation
validated against CrossRef.

Here, discovery is a name space: a driver agent whose `/mnt/sources/src`
holds those sources and whose `/mnt/sources/lookup` verifies what it
finds, writing a `works` file the corpus then reads in. First
interoperation: read PhilLit's BibTeX output and run `phil/cite` over
it, before any searching of our own.

## Measures, for the bench

`phil/cite` is measured before it is released, on the published
fixtures and not on one of our own: HALLMARK's 2,526 entries and
Badalova and Mayr's set (July 2026), with older monographs and pre-DOI
articles added for the `not-indexed` case neither covers. Two numbers,
kept apart: fabricated references detected, and real references
accepted. `phil/canon` is measured on the bench's own `pairs`
(Berkeley on Locke, Mill on Kant, Sidgwick on Mill) and on the
commentaries' citations of their sources.

## Order of work

1. `lib/phil/sources`: the sources, their order, thresholds and terms.
   `phil/cite` over Crossref and OpenAlex, with the fixtures above;
   `cite/not-indexed` from the first day.
2. Open Library, HathiTrust and loc.gov for monographs; OpenCitations
   for `cite/retracted`.
3. `lib/phil/canon` from hucitlib; `phil/canon`; `/n/perseus` cloned at
   a named commit and `/mnt/canon` serving it by URN; `phil/quote`.
   `pairs` rerun with citations resolved.
4. `claims/attributed-unread` says which `works` line would let it,
   with `cite`'s verdict on that line.
5. PhilPapers per user, after its terms are read.
6. The discovery agent's name space, and PhilLit's output read in.

## Open questions

- Does `phil/cite` belong here or in wwb? It serves any writer with a
  bibliography; its sources are a philosopher's. Proposed: the server
  and the canon here, a `claims -c` hook in wwb that calls `/mnt/sources/lookup`
  when it is mounted.
- Quotations in translation: `quote` against which edition? Proposed:
  the one the `works` line names, and `quote/edition-unnamed` when it
  names none.
- Whether a `cite/found` line should enter the corpus as provenance on
  a `works` line (`cite crossref 10.xxxx date`), so that a corpus says
  which of its works are on record. Proposed: yes, as a line the tool
  writes and nothing else may.
