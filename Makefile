.PHONY: setup run test docs ingest

setup:
	pip install -r ingestion/requirements.txt
	dbt deps

ingest:
	python ingestion/download_cms_data.py

run:
	dbt run

test:
	dbt test

docs:
	dbt docs generate && dbt docs serve
