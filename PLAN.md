# SNVariome Development Plan

## Product direction

SNVariome will be a mechanism-aware, variant-centered interactome for
investigating how a protein-altering variant may affect molecular function,
protein structure, and interaction networks. It will connect clinical variant
records, molecular mechanism annotations, protein structure,
protein-protein interactions, drug-gene relationships, phenotype context, and
perturbational signatures through stable identifiers and source-level
provenance.

The product will support variant interpretation and prioritization without
replacing general annotation tools or calculating a new pathogenicity score.
It will preserve the distinction between direct measurements, curated
classifications, computational predictions, contextual associations,
conflicts, and missing evidence.

The current PIK3CA dashboard is the first breast-cancer validation slice. It
tests the evidence architecture and allele-specific interaction workflow, but
it is not the complete scientific product.

## Core question

For a given protein-altering variant:

1. What variant is this?
2. What clinical interpretations and disease contexts have been reported?
3. Is a GOF, LOF, dominant-negative, haploinsufficiency, or other mechanism
   supported, and at what evidence level?
4. What structural features help explain that mechanism?
5. How clustered are known disease-associated residues in three-dimensional
   space, and is EDC applicable to this protein?
6. Which protein interactions are altered, unchanged, unmeasured, or predicted
   to change?
7. Which phenotypes, pathways, drug-gene relationships, and perturbational
   signatures provide additional context?
8. Which conclusions are direct, curated, predicted, contextual, conflicting,
   or missing?

## Intended first user

The initial user is a researcher evaluating a known protein-altering variant or
gene and seeking a concise mechanistic summary with direct access to the
underlying evidence.

## Validation slice and product scope

The first end-to-end validation slice supports a small, curated set of PIK3CA
variants represented in the project's existing references:

- p.Glu545Lys
- p.His1047Arg
- p.Met1043Val

For each PIK3CA variant, the application provides:

- Variant normalization and stable identifiers
- A variant evidence card
- Molecular and structural annotations
- Wild-type versus mutant interaction evidence
- A focused interaction-rewiring network
- Evidence provenance and retrieval dates
- A downloadable structured evidence record

This validation slice must remain functional while SNVariome expands to the
retained GOF/LOF source table. The next product milestone will support
dataset-backed search across those records by gene, rsID, Allele ID, genomic
position, and available transcript or protein notation. It will not claim to
support arbitrary variants until normalization and evidence retrieval have been
validated beyond the retained dataset.

## User workflow

1. The user enters a gene, rsID, Allele ID, genomic description, transcript
   notation, or protein notation supported by the indexed datasets.
2. SNVariome resolves the input and displays stable identifiers, mappings,
   ambiguities, and warnings.
3. The application retrieves versioned clinical and molecular-mechanism
   assertions without reconciling conflicts silently.
4. The user reviews structural features, stability results, interface context,
   and protein-level EDC where applicable.
5. The user explores wild-type versus mutant interactions and a focused
   evidence-aware network when allele-specific data are available.
6. The user reviews phenotype, pathway, drug-gene, and perturbational context
   without mistaking those associations for direct variant evidence.
7. The user opens the provenance for any assertion or interaction edge.
8. The user downloads the evidence bundle for further analysis.

## Core evidence model

The evidence contract will connect rather than collapse these seven layers:

| Layer | Role in interpretation |
| --- | --- |
| Clinical variants | Report external classifications, conditions, and review status |
| Molecular mechanisms | Preserve curated GOF, LOF, dominant-negative, haploinsufficiency, unknown, and conflicting assertions |
| Protein structure | Describe stability, domains, functional sites, interfaces, and EDC context |
| Protein interactions | Compare wild-type and mutant measurements or display labeled predictions |
| Drug-gene relationships | Provide traceable pharmacological context without recommending treatment |
| Phenotypes and pathways | Connect variants and genes to disease features and biological processes |
| Perturbational signatures | Generate downstream hypotheses from SigCom LINCS results |

A shared identifier layer must link variant, allele, gene, transcript, protein,
structure, interaction, compound, phenotype, pathway, signature, and source
records. No evidence layer may silently overwrite another layer's assertion.

## Variant evidence card

### Variant identity

- Submitted notation
- Normalized genomic and protein notation
- Reference genome assembly
- Transcript accession
- Protein accession
- Gene and HGNC identifier
- Normalization status and warnings

### Clinical evidence

- ClinVar classification
- Review status
- Associated condition
- Germline or somatic context
- Conflicting interpretations
- Source version and retrieval date

SNVariome will report source classifications without generating a new clinical
classification.

### Molecular mechanism

Mechanism terms will use a controlled vocabulary:

- Gain of function
- Loss of function
- Dominant negative
- Haploinsufficiency
- Altered localization
- Interaction perturbation
- Unknown
- Conflicting

Each mechanism assertion must identify its source and evidence class.

### Structural context

- Protein position and consequence
- Protein domains and functional regions
- Experimental structure coverage
- Predicted structure coverage
- Protein interaction interface proximity
- Ligand, active-site, and pocket proximity
- Post-translational modification proximity
- Estimated degree of disease-causing mutation clustering, when applicable

ProtVar can provide normalization and structural annotations where supported.
EDC will be displayed as contextual structural evidence. It will not be shown
as a per-variant pathogenicity prediction. The original EDC analysis required
pathogenic variants occurring at 10 or more distinct residues in a protein
structure.
The interface must show when this requirement is not met. An EDC value above
one indicates greater spatial clustering than expected under the study's
randomization procedure, but it does not establish pathogenicity or distinguish
GOF from dominant-negative mechanisms.

### Interaction rewiring

Every variant-partner relationship will use one of these states:

- Gained
- Lost
- Strengthened
- Weakened
- Unchanged
- Predicted disruption
- Unmeasured

An interaction record should retain:

- Variant and partner identifiers
- Wild-type measurement
- Mutant measurement
- Effect size and uncertainty
- Assay
- Cell line or biological model
- Publication identifier
- Figure, table, or supplemental-data location
- Evidence class
- Source version or retrieval date

The data model must distinguish absence of evidence, an interaction that was
not measured, and an interaction measured with no detectable change.

### Phenotype and pathway context

- HPO terms
- Disease associations
- Pathway membership
- Enrichment results
- Enrichment background universe

Short, unranked protein lists will use over-representation analysis rather than
standard gene set enrichment analysis. The background should represent the
proteins detectable or tested in the relevant experiment whenever possible.

### Drug-gene relationships

- Compound and target identifiers
- Relationship type and direction where reported
- Source database and source record
- Evidence level and biological context
- Retrieval date and database version

Drug-gene relationships will be presented as contextual associations. They will
not be described as variant-specific treatment recommendations unless the
specific allele and intervention were tested in the stated biological context.

### Perturbational hypotheses

LINCS results will be presented as downstream hypotheses. They will remain
visually and semantically separate from direct variant and interaction
evidence. A perturbational signature will not be described as evidence that a
compound rescues a specific variant unless that relationship was directly
tested.

## Evidence classification

SNVariome will not collapse heterogeneous evidence into one opaque score.
Every displayed assertion will receive an evidence class.

| Evidence class | Meaning |
| --- | --- |
| Direct experimental | The specific allele and effect were measured |
| Curated clinical | A clinical or expert resource curated the assertion |
| Computational prediction | A model predicts the effect |
| Contextual association | The evidence concerns the gene, residue, pathway, or phenotype but not the specific effect |
| Conflicting | Credible sources disagree |
| Missing | The question has not been evaluated or the source is unavailable |

Predicted evidence must not appear visually equivalent to direct experimental
evidence.

## Data and provenance requirements

The evidence bundle will be defined before substantial UI development. It
should support:

- Stable identifiers rather than display names as primary keys
- One source record for every assertion
- Publication and dataset identifiers
- Source versions and retrieval dates
- Row-level provenance for imported GOF/LOF labels
- Explicit distinction between gene-level and variant-level mechanism labels
- Explicit missing, unavailable, and not-applicable states
- Conflicting assertions without forced reconciliation
- Multiple assays and biological contexts for the same interaction
- Reproducible exports in a documented structured format

External responses should be cached or converted into versioned local fixtures
for development and testing. Source licenses and redistribution terms must be
recorded before including data in a public deployment.

The retained `goflof_ClinVar_v062021.csv` table contains 5,085 labeled
variants, including 555 GOF and 4,530 LOF records. Before ingestion, the source
release, label-generation method, coordinate assembly, identifier semantics,
license, and redistribution terms must be documented. Bayrak et al. must be
cited as the associated variant-level GOF/LOF resource. Gerasimavicius et al.
must be cited separately for the structural analyses and EDC framework that
used a Bayrak et al. mechanism dataset for external validation.

## Interface structure

The Shiny application will retain five focused dashboard views:

1. **Overview:** Dataset-backed gene and variant search, resolution status,
   warnings, and collection summaries
2. **Evidence:** Identity, clinical evidence, molecular mechanism, structure,
   EDC, phenotypes, pathways, drug-gene relationships, and hypotheses
3. **Interactions:** Searchable wild-type versus mutant records with assay and
   model details
4. **Network:** A focused variant-centered interaction graph with
   evidence-aware edge styling
5. **Sources:** Source records, methods, versions, retrieval dates, licensing
   notes, and structured evidence download

Selecting an assertion or network edge should open its evidence details. Large
generic interactomes will not be rendered by default. Evidence sections with no
applicable data must explain why the layer is unavailable rather than appearing
negative or silently disappearing.

## Implementation phases

### Existing foundation: Preserve the PIK3CA validation slice

- Keep the Rhino application structure, versioned evidence bundle, JSON Schema,
  tests, linting, `renv`, and container workflow.
- Preserve the three PIK3CA variants as the allele-specific interaction test
  case.
- Keep the evidence card and network driven by the same records.
- Continue to label unavailable clinical and structural data explicitly.

**Exit criterion:** Existing PIK3CA tests and the container smoke test remain
green throughout expansion.

### Phase 1: Audit and preserve the mechanism source data

- Retain the original GOF/LOF CSV as an immutable source artifact.
- Verify its acquisition source, release date, coordinate assembly, identifiers,
  label-generation method, checksum, license, and redistribution terms.
- Confirm whether each label is variant-level, gene-derived, or otherwise
  inferred.
- Profile duplicates, missing identifiers, conflicting labels, and variant
  classes.
- Correctly distinguish the roles of Bayrak et al. and Gerasimavicius et al. in
  project documentation.

**Exit criterion:** Every retained column and label has a documented meaning and
provenance, and the source can be transformed reproducibly without manual
spreadsheet editing.

### Phase 2: Extend the evidence contract

- Represent row-level molecular-mechanism assertions with source, scope,
  method, version, and uncertainty.
- Represent EDC as protein- and structure-level contextual evidence rather than
  a variant score.
- Add typed records for clinical, structural, phenotype, pathway, drug-gene,
  and perturbational-signature evidence.
- Define cross-layer identifiers and conflict rules.
- Preserve backward compatibility with the PIK3CA demonstration bundle.

**Exit criterion:** Representative GOF, LOF, conflicting, unmapped, and
PIK3CA interaction records validate without discarding their original context.

### Phase 3: Add dataset-backed gene and variant search

- Transform the audited GOF/LOF source into a versioned application fixture.
- Resolve gene symbols, rsIDs, Allele IDs, genomic positions, and available
  transcript or protein descriptions.
- Return all plausible matches when an input is ambiguous.
- Display mechanism labels with their evidence scope and provenance.
- Keep unmatched input distinct from a negative or unknown mechanism label.

**Exit criterion:** A user can search every retained GOF/LOF record and trace
the displayed label back to its exact source row.

### Phase 4: Add clinical and structural context

- Add versioned ClinVar evidence without deriving a new classification.
- Retrieve and audit the structural and EDC outputs associated with
  Gerasimavicius et al.
- Map variants to proteins and structures with explicit transcript and assembly
  handling.
- Integrate ProtVar annotations where supported.
- Display stability, interface, domain, functional-site, and EDC context with
  method-specific limitations.
- Mark EDC unavailable when its residue-count or structure requirements are not
  met.

**Exit criterion:** A mechanism-labeled variant can be reviewed alongside
clinical and structural evidence without treating EDC as a variant-specific
pathogenicity prediction.

### Phase 5: Complete the interaction-rewiring validation case

- Preserve wild-type versus mutant PIK3CA results from Kim et al.
- Complete extraction of exact quantitative results from the cited supplement
  when available.
- Identify the tested or detectable protein universe.
- Remove or correctly label experimental controls such as NTC1 and NTC2.
- Support allele-to-allele comparison within PIK3CA.
- Expose assay, biological model, uncertainty, and source location for every
  edge.

**Exit criterion:** Every displayed PIK3CA interaction is traceable to a source
location, and the evidence card and network cannot disagree.

### Phase 6: Add phenotype, pathway, and drug-gene context

- Link HPO terms and disease associations through stable identifiers.
- Add pathway membership and appropriately defined enrichment analyses.
- Add versioned drug-gene relationships with source and relationship type.
- Keep gene-level and pathway-level associations visually distinct from
  allele-specific evidence.

**Exit criterion:** Contextual evidence broadens interpretation without being
presented as direct proof of a variant mechanism or treatment response.

### Phase 7: Add perturbational hypotheses

- Integrate SigCom LINCS only after the direct and curated evidence layers are
  stable.
- Record query inputs, signature identifiers, direction, model system, version,
  and retrieval date.
- Present connections between variants, pathways, and signatures as hypotheses.
- Do not describe a compound as rescuing a variant without direct evidence.

**Exit criterion:** Every signature result is reproducible and cannot be
mistaken for a drug recommendation or variant-specific experiment.

### Phase 8: Validate and extend

- Test with domain researchers using defined interpretation tasks.
- Retain PIK3CA as the breast-cancer interaction benchmark.
- Add BRCA1 as a mechanistically distinct network benchmark only after its
  evidence sources are curated.
- Measure search coverage, unresolved mappings, and missing evidence by source.
- Expand beyond the retained dataset only when normalization, provenance, and
  evidence semantics are validated.

**Exit criterion:** Users can distinguish measured effects from predictions,
trace every substantive claim to its source, and understand why an evidence
layer is present, absent, or inapplicable.

## Initial validation cases

The test set should include:

- A GOF source row and a LOF source row
- A duplicate or conflicting mechanism label
- A gene-level mechanism assertion that must not be presented as variant-level
- A source row that cannot be mapped to the selected assembly or transcript
- Alternate notations that describe the same allele
- An ambiguous or invalid variant description
- Conflicting clinical assertions
- A protein eligible for EDC and one with insufficient mutated residues
- Missing experimental structure coverage
- An interaction measured with no change
- An interaction that was not measured
- A predicted interaction effect without experimental support
- Duplicate or reciprocal PPI records
- A partial or unavailable upstream API response

## Deferred scope

The following features are intentionally outside the minimum viable product:

- Genome-wide precomputation
- Automated clinical classification
- A composite pathogenicity score
- General drug recommendations
- Live, unrestricted LINCS querying before reproducible signature fixtures
- Large generic interactome exploration
- Uncited generative summaries

An automated narrative layer may later summarize structured evidence. It must
cite the underlying records and must not invent evidence or reconcile conflicts
without an explicit rule.

## Principal risks

### Evidence comparability

Interaction assays, cell lines, and effect measures are not interchangeable.
The schema and UI must preserve these contexts.

### Mechanism-label provenance

GOF and LOF labels may be curated at the variant level, propagated from a gene,
or inferred computationally. These scopes are not interchangeable. The source
audit and evidence schema must preserve how every label was produced.

### EDC interpretation

EDC summarizes the spatial distribution of known disease-associated residues
for an eligible protein structure. It is not a per-variant score, does not prove
pathogenicity, and does not distinguish GOF from dominant-negative mechanisms.
The interface must preserve the source study's eligibility criteria and
randomization context.

### Source availability

External APIs can change or become unavailable. Cached fixtures, clear failure
states, and source versioning are required.

### Data licensing

Some sources may permit querying but restrict redistribution. Licensing review
must precede public bundling or deployment.

### Overinterpretation

Structural proximity, network association, and perturbational similarity do not
establish pathogenicity or causal interaction rewiring. The interface must keep
these evidence layers separate.

### Scope expansion

Claiming arbitrary-variant support too early would hide weaknesses in
normalization, provenance, and evidence semantics. Expansion should proceed
first across the bounded GOF/LOF source table while retaining PIK3CA as the
interaction-rewiring benchmark.

## Definition of the next milestone

The next milestone is complete when the retained GOF/LOF dataset has been
audited, transformed reproducibly, and connected to dataset-backed search. A
user must be able to find a retained variant or gene, inspect its GOF or LOF
label with row-level provenance, and see clearly which clinical, structural,
EDC, and interaction layers are available or missing. The existing PIK3CA
evidence card and rewiring network must continue to pass their tests and
container smoke test.
