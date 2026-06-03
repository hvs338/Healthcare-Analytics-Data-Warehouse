# Side Project Plans — Harold Smith

---

## Project 1: Healthcare Analytics Data Warehouse (dbt + DuckDB)

**Goal:** A public, end-to-end data warehouse project that proves you can do dbt, dimensional modeling, and tested SQL transformations — all viewable on GitHub. Uses DuckDB instead of Snowflake so anyone (including recruiters) can clone and run it with zero cloud costs.

**Dataset:** CMS (Centers for Medicare & Medicaid Services) public data — stays in your healthcare domain and signals domain expertise. Specifically, the Medicare Provider Utilization & Payment Data, Hospital Compare quality metrics, and CMS geographic variation files. All free, all public, all large enough to be interesting.

**Why this project fills gaps on your resume:**

- dbt and Airflow move from "learning" to "demonstrated"
- Your 668+ SQL artifacts are behind a client wall — this gives recruiters something they can actually read
- Medallion architecture + testing + docs shows you think about data quality, not just transforms
- Healthcare domain continuity with your Deloitte VA work

### Repo Structure

```
cms-healthcare-warehouse/
├── README.md                  # Project overview, architecture diagram, how to run
├── dbt_project.yml
├── profiles.yml               # DuckDB local profile
├── packages.yml               # dbt-utils, dbt-expectations
│
├── seeds/                     # Small reference tables (state codes, specialty codes)
│   └── specialty_codes.csv
│
├── models/
│   ├── staging/               # 1:1 with raw sources, rename + type cast only
│   │   ├── stg_provider_utilization.sql
│   │   ├── stg_hospital_quality.sql
│   │   ├── stg_geographic_variation.sql
│   │   └── _staging_schema.yml        # Column-level docs + tests
│   │
│   ├── intermediate/          # Business logic joins, deduplication, SCD2
│   │   ├── int_provider_specialty_metrics.sql
│   │   ├── int_hospital_quality_scored.sql
│   │   └── int_geographic_cost_benchmarks.sql
│   │
│   └── marts/                 # Star schema, analytics-ready
│       ├── dim_provider.sql
│       ├── dim_hospital.sql
│       ├── dim_geography.sql
│       ├── fct_provider_services.sql
│       ├── fct_hospital_quality.sql
│       └── _marts_schema.yml          # Final tests + docs
│
├── macros/                    # Reusable SQL (e.g., percentile calc, null audit)
│   └── calculate_percentile.sql
│
├── tests/                     # Custom singular tests
│   └── assert_no_orphan_providers.sql
│
├── analyses/                  # Ad-hoc queries showing what the warehouse enables
│   ├── top_specialists_by_cost.sql
│   └── quality_vs_cost_correlation.sql
│
├── orchestration/             # Airflow DAGs (or Dagster if you prefer)
│   └── dags/
│       └── cms_warehouse_refresh.py
│
├── ingestion/                 # Python scripts to pull CMS data into local parquet
│   ├── download_cms_data.py
│   └── requirements.txt
│
├── streamlit_app/             # Simple dashboard on top of the warehouse
│   └── app.py
│
├── docs/                      # Architecture decision records
│   ├── architecture.md
│   └── data_dictionary.md
│
└── Makefile                   # `make setup`, `make run`, `make test`, `make docs`
```

### Build Plan (Weekends, ~4-6 Weeks)

**Week 1 — Ingestion + Staging**

- Download 3-4 CMS datasets (provider utilization, hospital compare, geographic variation)
- Write Python scripts to fetch, unzip, and convert to Parquet
- Initialize dbt project with DuckDB adapter
- Build staging models: 1:1 source mirrors with renaming, type casting, null handling
- Add schema.yml with column descriptions and basic tests (not_null, unique, accepted_values)
- Commit to GitHub with a clear README

**Week 2 — Intermediate Models + Business Logic**

- Build intermediate models that join across sources (e.g., provider metrics by specialty and geography)
- Implement SCD2 logic for slowly changing dimensions (if using multiple years of CMS data)
- Add deduplication logic and document assumptions
- Write custom tests (referential integrity, row count thresholds)
- Install dbt-expectations for more expressive tests (e.g., expect_column_values_to_be_between)

**Week 3 — Marts + Star Schema**

- Build dimension tables (provider, hospital, geography) and fact tables (services, quality scores)
- Add incremental materialization where it makes sense
- Write analysis queries that demonstrate what the warehouse enables (top providers by cost efficiency, quality-vs-cost scatter data)
- Generate dbt docs and host on GitHub Pages

**Week 4 — Orchestration**

- Write an Airflow DAG that runs: ingestion → dbt run → dbt test → alert on failure
- Dockerize the whole stack (Airflow + DuckDB + dbt) so anyone can `docker-compose up`
- Add a Makefile with `make setup`, `make run`, `make test` for quick onboarding

**Week 5 — Dashboard + Polish**

- Build a Streamlit app that queries the mart tables and shows 3-4 key views (provider cost map, quality rankings, geographic benchmarks)
- Write a proper README with architecture diagram, data lineage screenshot from dbt docs, and a "what I'd do differently in production" section
- Add a DECISIONS.md explaining tradeoffs (why DuckDB over Snowflake, why this schema shape, etc.)

**Week 6 — Buffer / Blog Post**

- Write a short blog post or LinkedIn article walking through the project
- Clean up commit history, add CI (GitHub Actions running `dbt build` on every PR)

### What to Emphasize in the README

- Architecture diagram showing the full pipeline (ingestion → staging → intermediate → marts → dashboard)
- Data lineage from dbt docs (screenshot or hosted link)
- "Production considerations" section: what you'd change at scale (swap DuckDB for Snowflake/BigQuery, add data contracts, partition strategy, cost monitoring)
- Link analyses to actual healthcare questions ("Which specialties have the widest cost variation across states?")

---

## Project 2: RAG App — Healthcare Policy Q&A Agent

**Goal:** A retrieval-augmented generation chatbot that answers questions about healthcare policy documents with cited sources. Extends your Bedrock/LLM experience into the retrieval and embedding layer, which is the most in-demand AI engineering pattern right now.

**Dataset:** Public VA/CMS policy documents, Federal Register healthcare rules, or CMS Medicare manuals. PDFs and HTML — messy, real-world documents that require chunking strategy.

**Why this project fills gaps on your resume:**

- Extends your Bedrock contact center work into full RAG architecture
- Shows you understand embeddings, vector search, and retrieval — not just prompt engineering
- The data pipeline underneath (document ingestion, chunking, embedding, indexing) bridges your DE skills with AI
- Healthcare domain again = consistent narrative

### Repo Structure

```
healthcare-rag-agent/
├── README.md
├── pyproject.toml              # or requirements.txt
│
├── ingestion/                  # Document pipeline
│   ├── sources.yml             # URLs / paths to policy docs
│   ├── download.py             # Fetch PDFs and HTML
│   ├── parse.py                # Extract text (PyMuPDF for PDFs, BeautifulSoup for HTML)
│   ├── chunk.py                # Chunking strategies (recursive, semantic)
│   └── embed_and_index.py      # Generate embeddings → upsert to vector store
│
├── retrieval/
│   ├── vector_store.py         # Abstraction over pgvector / Pinecone / ChromaDB
│   ├── retriever.py            # Query embedding → top-k retrieval → reranking
│   └── hybrid_search.py        # Optional: combine vector + keyword (BM25) search
│
├── generation/
│   ├── prompt_templates.py     # System prompts with citation instructions
│   ├── chain.py                # Retrieval → context assembly → LLM call → parse citations
│   └── bedrock_client.py       # AWS Bedrock integration (Claude via Bedrock)
│
├── evaluation/                 # This is what separates good RAG from demo RAG
│   ├── eval_dataset.json       # 50+ question-answer pairs with source references
│   ├── run_eval.py             # Automated eval: retrieval recall, answer correctness, citation accuracy
│   ├── metrics.py              # Faithfulness, relevance, hallucination rate
│   └── results/                # Stored eval runs for comparison
│
├── api/
│   ├── main.py                 # FastAPI app
│   └── schemas.py              # Request/response models
│
├── ui/
│   └── app.py                  # Streamlit chat interface with source citations
│
├── infra/                      # Optional but impressive
│   ├── Dockerfile
│   ├── docker-compose.yml      # App + Postgres (pgvector) + optional Redis cache
│   └── cdk/                    # AWS CDK if you want to deploy (ties to your CDK skills)
│
├── notebooks/
│   ├── 01_chunking_experiments.ipynb    # Compare chunk sizes, overlap, strategies
│   └── 02_retrieval_analysis.ipynb      # Visualize embedding clusters, retrieval quality
│
├── tests/
│   ├── test_chunking.py
│   ├── test_retrieval.py
│   └── test_generation.py
│
└── docs/
    ├── architecture.md
    └── chunking_strategy.md
```

### Build Plan (Evenings + Weekends, ~5-7 Weeks)

**Week 1 — Document Ingestion Pipeline**

- Collect 20-30 public healthcare policy PDFs (VA benefits guides, CMS manuals, Federal Register rules)
- Build parsing pipeline: PDF → text extraction (PyMuPDF), HTML → BeautifulSoup
- Handle messy formatting: tables, headers, footnotes, multi-column layouts
- Store raw text + metadata (source URL, doc title, page number) in structured format
- This is the DE part — treat it like an ETL pipeline, not a notebook hack

**Week 2 — Chunking + Embeddings**

- Implement 2-3 chunking strategies in a notebook:
  - Fixed-size with overlap (baseline)
  - Recursive character splitting (LangChain-style)
  - Semantic chunking (split on topic shifts using embedding similarity)
- Compare them: chunk size distribution, semantic coherence, retrieval quality
- Generate embeddings (Amazon Titan Embeddings via Bedrock, or open-source like sentence-transformers)
- Stand up pgvector (Postgres extension) in Docker and index all chunks
- Document your chunking decision in `docs/chunking_strategy.md`

**Week 3 — Retrieval Layer**

- Build the retriever: query embedding → cosine similarity search → top-k results
- Add metadata filtering (filter by document type, date range, topic)
- Implement hybrid search: combine vector similarity with BM25 keyword matching
- Test retrieval quality manually: ask 10 questions, check if the right chunks come back
- Add a reranker (cross-encoder or Cohere Rerank) to improve precision

**Week 4 — Generation + Citations**

- Build the generation chain: retrieved chunks → prompt template → Bedrock (Claude) → response with citations
- Prompt engineering: system prompt instructs the model to cite specific chunks by reference, refuse to answer if context is insufficient, and distinguish between what the documents say vs. general knowledge
- Parse citations from LLM output and map back to source documents + page numbers
- Build the FastAPI endpoint: POST question → response with answer + sources

**Week 5 — Evaluation Pipeline (This Is the Differentiator)**

- Build an eval dataset: 50+ questions with known answers and source references
- Automate evaluation metrics:
  - Retrieval recall: did the correct chunks get retrieved?
  - Answer faithfulness: is the answer supported by the retrieved context?
  - Citation accuracy: do the citations actually support the claims?
  - Hallucination rate: how often does the model make unsupported claims?
- Store eval results as structured data so you can compare across experiments
- This is what separates "I built a chatbot" from "I built a production-grade RAG system"

**Week 6 — UI + Infrastructure**

- Build a Streamlit chat interface: question input, streaming response, expandable source citations with links back to original docs
- Dockerize everything: app + pgvector + API
- Optional: deploy on AWS with CDK (Lambda + RDS + API Gateway) — ties directly to your CDK experience on your resume
- Add caching layer (Redis or simple in-memory) for repeated queries

**Week 7 — Polish + Write-Up**

- Clean README with architecture diagram, demo GIF, and setup instructions
- Write `docs/architecture.md` explaining design decisions
- Notebooks should be clean and narrative (not scratch work)
- "Production considerations" section: how you'd handle document updates, embedding drift, cost at scale, auth, rate limiting
- Blog post or LinkedIn write-up showing retrieval quality improvements across experiments

### What to Emphasize in the README

- Architecture diagram: document pipeline → vector store → retrieval → generation → UI
- Evaluation results table showing metrics across different configurations
- "Why RAG over fine-tuning" section (shows you understand the tradeoff space)
- Screenshots of the chat UI with real questions and cited answers
- Link to your Bedrock contact center work on your resume to tell a cohesive story

---

## How These Projects Work Together on Your Resume

Add a **Projects** section between Experience and Technical Skills:

**CMS Healthcare Data Warehouse** — dbt, DuckDB, Airflow, Streamlit
Built an open-source analytics warehouse over CMS public data with 15+ dbt models across staging/intermediate/mart layers, automated testing, orchestrated with Airflow, and visualized in Streamlit. [GitHub link]

**Healthcare Policy RAG Agent** — Bedrock, pgvector, FastAPI, Streamlit
Built a retrieval-augmented generation chatbot that answers healthcare policy questions with cited sources. Includes document ingestion pipeline, hybrid vector + keyword search, automated evaluation framework measuring retrieval recall and faithfulness. [GitHub link]

These two projects together say: "I build the data infrastructure AND the AI systems that run on top of it." That's the story.
