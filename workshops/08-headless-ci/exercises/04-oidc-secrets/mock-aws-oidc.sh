#!/usr/bin/env bash
# Mock simulation of GitLab CI → AWS Bedrock OIDC flow.
# Mirrors https://code.claude.com/docs/en/gitlab-ci-cd#aws-bedrock-job-example-oidc

set -euo pipefail

echo "=== Stage 1: GitLab issues OIDC JWT ==="
# In real CI, GitLab provides this in CI_JOB_JWT_V2 env var.
export CI_JOB_JWT_V2="mock.jwt.payload-$(date +%s)"
echo "CI_JOB_JWT_V2 = $CI_JOB_JWT_V2"
echo

echo "=== Stage 2: write JWT to file (aws cli expects file:// URI) ==="
export AWS_WEB_IDENTITY_TOKEN_FILE="/tmp/oidc_token_$$"
printf "%s" "$CI_JOB_JWT_V2" > "$AWS_WEB_IDENTITY_TOKEN_FILE"
echo "Wrote token to: $AWS_WEB_IDENTITY_TOKEN_FILE"
echo

echo "=== Stage 3: assume-role-with-web-identity (mocked) ==="
# In real CI:
#   aws sts assume-role-with-web-identity \
#     --role-arn "$AWS_ROLE_TO_ASSUME" \
#     --role-session-name "gitlab-claude-$(date +%s)" \
#     --web-identity-token "file://$AWS_WEB_IDENTITY_TOKEN_FILE" \
#     --duration-seconds 3600 > /tmp/aws_creds.json
cat > /tmp/aws_creds.json <<EOF
{
  "Credentials": {
    "AccessKeyId": "ASIAMOCK1234567890AB",
    "SecretAccessKey": "mockSecret/AbcDefGhiJklMnoPqrStuVwx0123456789",
    "SessionToken": "FakeSessionToken-$(date +%s)",
    "Expiration": "$(date -u -d '+1 hour' '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || date -u -v+1H '+%Y-%m-%dT%H:%M:%SZ')"
  }
}
EOF
echo "Mock STS response written to /tmp/aws_creds.json"
cat /tmp/aws_creds.json | (command -v jq >/dev/null && jq . || cat)
echo

echo "=== Stage 4: export AWS env vars ==="
export AWS_ACCESS_KEY_ID="$(jq -r .Credentials.AccessKeyId /tmp/aws_creds.json)"
export AWS_SECRET_ACCESS_KEY="$(jq -r .Credentials.SecretAccessKey /tmp/aws_creds.json)"
export AWS_SESSION_TOKEN="$(jq -r .Credentials.SessionToken /tmp/aws_creds.json)"
export AWS_REGION="${AWS_REGION:-us-west-2}"
echo "AWS_ACCESS_KEY_ID = ${AWS_ACCESS_KEY_ID:0:8}... (mock)"
echo "AWS_REGION        = $AWS_REGION"
echo

echo "=== Stage 5: now would run claude with Bedrock ==="
echo "  export CLAUDE_CODE_USE_BEDROCK=1"
echo "  claude -p 'review this MR' --permission-mode plan --max-turns 3"
echo
echo "(Skipping actual claude run — creds are mocked)"
rm -f "$AWS_WEB_IDENTITY_TOKEN_FILE" /tmp/aws_creds.json
echo "Mock cleanup done."
