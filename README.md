[Rultor](https://github.com/yegor256/rultor) as GitHub action:
1) add action to PR review workflow,
2) put merge comment into review comments
3) this action will merge PR into master with running
 tests from `.rultor.yml`

## Install

Configure Rultor: commit `.rultor.yml` configuration file
into repository, see [documentation](https://doc.rultor.com/reference.html)
for details.

Configure GitHub workflow:
 1. Create new workflow in `.github/workflows` directory,
you may call it `.github/worflows/rultor.yml`
 2. Listen for `pull_request_review` events:
 ```yml
 "on": [pull_request_review]
 ```
 3. Add checkout step before this action:
 ```yml
 - name: Checkout
   uses: actions/checkout@v1
 ```
 4. Add `rultor-action`, provide `GITHUB_TOKEN` input:
 ```yml
 - name: rultor
   uses: g4s8/rultor-action@master
   with:
     token: ${{ secrets.GITHUB_TOKEN }}
 ```

Workflow example:
```yml
---
name: rultor
"on": pull_request_review
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v1
      - name: Rultor
        uses: g4s8/rultor-action@master
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
```

Now you can put `merge` message in PR review comments,
and this action will checkout into `origin/master`, merge
PR branch into `master`, run tests defined in `.rultor.yml`,
and push it to `origin/master` on success.
