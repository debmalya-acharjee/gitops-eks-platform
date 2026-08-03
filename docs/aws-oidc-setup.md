# GitHub Actions → AWS OIDC Setup (no long-lived AWS keys)

This lets GitHub Actions assume an AWS IAM role for the CI workflow, without
ever storing an AWS access key/secret as a GitHub Secret. This is the
current best practice and worth mentioning explicitly in an interview.

## 1. Create the OIDC identity provider (one-time, per AWS account)

```bash
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

(Skip this step if your AWS account already has this provider from another project.)

## 2. Create the IAM role with a trust policy scoped to YOUR repo only

Save as `trust-policy.json` (replace placeholders):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:YOUR-GITHUB-USERNAME/YOUR-REPO-NAME:*"
        }
      }
    }
  ]
}
```

The `StringLike` condition is the important part — it restricts this role so
ONLY workflows running from your specific repo can assume it. Without this,
any GitHub Actions workflow anywhere could potentially assume the role.

```bash
aws iam create-role \
  --role-name github-actions-ecr-push \
  --assume-role-policy-document file://trust-policy.json
```

## 3. Attach a minimal permissions policy (least privilege — not AdministratorAccess)

```bash
aws iam put-role-policy \
  --role-name github-actions-ecr-push \
  --policy-name ecr-push-only \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ecr:GetAuthorizationToken"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ],
        "Resource": "arn:aws:ecr:eu-central-1:YOUR_ACCOUNT_ID:repository/sample-api"
      }
    ]
  }'
```

## 4. Put the role ARN into the workflow — NOT as a secret, this is fine to be public

The role ARN itself isn't sensitive (it's useless without the trust policy
restricting who can assume it), so it's fine directly in
`.github/workflows/ci.yaml`:

```yaml
role-to-assume: arn:aws:iam::YOUR_ACCOUNT_ID:role/github-actions-ecr-push
```

Your AWS Account ID itself is also not considered a secret by AWS, but if you'd
rather not publish it in a public repo, store it as a GitHub Actions repo
variable (Settings → Secrets and variables → Actions → Variables, not Secrets)
and reference it as `${{ vars.AWS_ACCOUNT_ID }}` instead.
