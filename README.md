# Bookdown Heavy Testing

This repo is designed to run regression tests of proposed bookdown changes. It builds several bookdown books with two bookdown versions (typically tip of main and the branch under test) and compares the results within a github action.

# Interpretting results

This compares results of two versions of `bookdown`. The `in-bookdown-main` and `in-bookdown-test` specify these versions. In `main` of this repo (`bookdown-heavy-testing`), both of these point to the same version  of bookdown, so any differences are the result of non-determinism.

All submodules except `in-bookdown-test` contain books that are compiled by this test. So `in-bookdown-main` serves a dual purpose: providing the basely code to compare `in-bookdown-test` to and providing one of the books to compile.

# Using this repo to test your branch

These instructions assume you are already familiar with the workflow to fork, push to branch, make a PR, but may not be terribly familliar with git submodules.

## Setting up and testing your branch for the first time

0. Make your change in bookdown and push to a fork of the bookdown repo. 
1. Clone/pull latest for this (`bookdown-heavy-testing`) repo. Since it has submodules, in addition to `git clone` or `git pull` you will likely also need to run `git submodule update --init --recursive` from inside the repo.
2. Create a fork and a new branch from `bookdown-heavy-testing` repo as you normally would if you planned to contribute to the repo.
3. Update the `in-bookdown-test` submodule to point to the `bookdown` repo branch that you want to test. Switch the url of this submodule to your fork:

```
git submodule set-url in-bookdown-test git@github.com:YOUR_GITHUB_USERNAME/bookdown.git
```
Checkout the branch you want to test:
```
git -C ./in-bookdown-test/ fetch
git -C ./in-bookdown-test/ checkout YOUR_BOOKDOWN_BRANCH_NAME
```
Git status should now look like this:
```
On branch YOUR_BOOKDOWN_HEAVY_TESTING_BRANCH
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   .gitmodules
        modified:   in-bookdown-test (new commits)
```
4. Commit and push submodule changes to your `bookdown-heavy-testing` fork. 
5. Make a PR and wait for CI. (Good idea to mark it as a draft, since it is not intended to be merged.)
6. Examine the diff. Within the github action "Results" has which files and lines changed and "Full Results" has the actual changes.

## Testing new changes in **your** bookdown branch

Your `bookdown-heay-testing` branch will not automatically update when you update your `bookdown` branch. You will need to fol

0. Make sure you have pushed your changes to your bookdown fork.
1. Inside `bookdown-heavy-testing`, with your `bookdown-heavy-testing` branch checked out
Run:

```
git submodule update --remote in-bookdown-test
```

`git status` should now show this:
```
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   in-bookdown-test (new commits)
```
2. Commit and push these changes.



## Updating your branches based on upstream changes.

1. Update your `bookdown` branch (merge in main or rebase and push). 
2. Update your `bookdown-heavy-testing` branch to reflect the change to your `bookdown` branch as described above.
3. Update the `in-bookdown-main` link: from your `bookdown-heavy-testing` branch, run

```
git submodule update --remote in-bookdown-main
```

Commit and push these changes. It doesn't really matter that you generating a different commit history from the main branch of `bookdown-heavy-testing` because the point of your branch/PR is just to test a branch of a different repo (`bookdown`), not to merge.

## Note about locally switching branches
If you are switching between branches of `bookdown-heavy-tesing` that where the submodules are pointing to different places, in addition to `git checkout`, you will need to run `git submodule update` when changing branches. This will get you back to the version of the

# Adding a book

1. Add the book as a submodule in the format `in-bookname`.
2. Add the book to `books-to-test.yml` in the format `bookname: path/to/book`.
3. Add any Linux dependencies to the dockerfile.
4. Add any R dependencies to env-base (e.g. `renv::record(YOUR_R_PKG, project='env-base'))`).
5. Add known non-deterministic sections to exceptions. The easiest way to do this is to first run [run_test.R]. (You can edit [books-to-test.yml] to include only the new book to speed things up). Then, source `parse-diff.R`, then `write_diffs(dir_diff('out-main/', 'out-test/', 'newexceptions.yml'))`. Examine the generated files: `results.txt`, `full_results.txt`, and `newexceptions.yml` to make sure they represent changes you would expect to see from run to run. If everything looks good, add the contents of `new_exceptions.yml` to `exceptions.yml`. 
