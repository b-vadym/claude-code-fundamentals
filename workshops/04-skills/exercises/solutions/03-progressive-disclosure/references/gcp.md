# GCP deploy reference

## Prerequisites

- `gcloud` CLI installed and authenticated
- `yq` for parsing `gcloud-config.yaml`

## Steps

1. Verify auth:
   ```bash
   gcloud auth list
   gcloud config get-value project
   ```
   If no active account, run `gcloud auth login`.

2. Set project from config:
   ```bash
   project=$(yq '.project' gcloud-config.yaml)
   gcloud config set project "$project"
   ```

3. Enable required APIs:
   ```bash
   gcloud services enable run.googleapis.com cloudbuild.googleapis.com
   ```

4. Build container:
   ```bash
   service=$(yq '.service' gcloud-config.yaml)
   gcloud builds submit --tag "gcr.io/$project/$service"
   ```

5. Deploy to Cloud Run:
   ```bash
   region=$(yq '.region // "us-central1"' gcloud-config.yaml)
   gcloud run deploy "$service" \
     --image "gcr.io/$project/$service" \
     --region "$region"
   ```

6. Capture service URL:
   ```bash
   gcloud run services describe "$service" \
     --format='value(status.url)'
   ```

7. Health check: curl service URL, expect 200.

## Rollback

If 5xx or user requests rollback:

```bash
gcloud run services delete "$service" --quiet
```

⚠️ Confirm with user before delete.
