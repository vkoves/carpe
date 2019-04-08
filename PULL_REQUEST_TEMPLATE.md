_Add a clear descriptive title above. This should describe the basics of what the pull request does and should not contain issue numbers. **Note:** Make sure to delete all placeholder italics text. It is here to help you fill out this template, but should not be in the submitted PR._

## Description
_Describe the approach taken to solving the problem, all changes made by the pull request, and any anticipated risks for breaking other work. If the changes made are primarily visual, you should show GIFs or screenshots of your changes._

## Type of Pull Request
Based on the [contributor's guide][contrib-guide], this PR is of type:

- [ ] Development (`feature-branch` -> `dev`)
- [ ] Hotfix (`hotfix-branch` -> `master`)
- [ ] Release (`release-branch` -> `master`)
- [ ] Other

## Requestor Checklist
**Requestor**: Put an `x` in all that apply. You can check boxes after the PR has been made.

**Reviewer**: If you see an item that is not checked that you believe should be, comment on that as part of your review.

- [ ] Code Quality: I have written tests to ensure that my changes work and handle edge cases
- [ ] Code Quality: I have documented my changes thoroughly (using [JSDoc][jsdoc] in Javascript)
- [ ] Process: I have linked relevant issues, [marking issues][gh-marking-issues] that this PR resolves
- [ ] Process: I have requested at least as many reviews required for this PR type (2 or 3)
- [ ] Process: I have added this PR to the relevant quarterly milestone
- [ ] Process: I have tested this PR locally and verified it does what it should

### Hotfixes & Deployments
_If this is not a hotfix or release, delete this section._
- [ ] Process: I have assigned a user to this PR to handle merging and deployment
- [ ] Process: I have pushed up my changes to [Carpe test][carpe-test] for review and tested my changes there

## How This Has Been Tested
_Give specific details of how you tested these changes to ensure that they work and don't break other functionality. Details may include device, browser, and what actions/cases you tested._

## Release & Hotfix Checklist
_If this is not a hotfix or release, delete this section._

The assignee should complete this checklist from [deploying Carpe][contrib-guide-deploying] section of the contributor's guide before and after deploying a deployment or hotfix.

- [ ] Before Release/Hotfix: I have verified that this PR meets the [requirements for reviews][contrib-guide-prs]
- [ ] Before Release: I have moved all issuses labelled `development` to `release-candidate`
- [ ] Before Release: I have verified the release candidate has been frozen for at least 48 hours
- [ ] After Release: I have removed the `release-candidate` label from all issues marked with it
- [ ] After Release/Hotfix: I have created a PR from `master` into `dev` to update dev with changes made on a release/hotfix branch





[contrib-guide]: CONTRIBUTING.md
[contrib-guide-prs]: CONTRIBUTING.md#creating-pull-requests
[contrib-guide-deploying]: CONTRIBUTING.md#deploying-carpe
[gh-marking-issues]: https://help.github.com/articles/closing-issues-using-keywords/
[carpe-test]: https://carpe-test.herokuapp.com/
[jsdoc]: http://usejsdoc.org/about-getting-started.html
