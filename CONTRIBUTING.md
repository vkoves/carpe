# Contributing to Carpe

## Creating Issues

Issues are how we track work to be done on Carpe, including bugs and features.
If you think there's something that needs to get done on Carpe, an issue is how you can start that process.
This part of the contribution guide describes how to create issues for bugs and enhancements.

### Reporting Bugs
One of the most common types of issues are bugs. If you find a bug on Carpe, follow these steps:

- Check if the bug has already been reported - a quick search through our open issues should show you if
you are the first person reporting this bug. If someone else has reported the bug, you might want to add
your voice to the conversation to indicate that the issue can be replicated.
- Report the bug - If the bug hasn't been reported yet, create a new issue with the label *bug* and any other relevant labels. When creating
an issue for a bug make sure to:
	- **Write a clear title** - this makes it easy to sort through issues and find ones that might be more urgent
	or touch certain code.
	- **Describe steps for recreating the bug** - step-by-step instructions will make it possible for others to
	reproduce the issue and debug it, so the better the instructions, the more likely the problem will get
	solved.
	- **Provide environment information** - a bug report should contain the browser and operating system you were using
	when you found the bug, which should include version numbers.
	- **Give a bug priority** - at the end of the issue specify a priority for the bug (both in the issue text and as a label) and why you believe it is that
	priority. If you are unsure of a bug priority, ask for a second opinion. See the bug priorities section later in this document.
	- **Label the bug** - apply any relevant label to the bug via GitHub issue labels, so that it can easily be found by
	team members working on specific sets of bugs. In particular, make sure to label a bug as "development" or "release-candidate". Bugs not marked as development or release-candidate are assumed to be on production.

#### Bug Priorities

- **Critical** - A critical Carpe function does not work at all for a significant portion of users. Some examples of core functionality:
	- Creating events
	- Signing in
	- Loading the dashboard
	- Viewing another user's schedule
- **High** - Core functionality is impaired (partially not working) or non-core functionality on Carpe is not working at all.
- **Medium** - Non-core functionality is impaired or core functionality has a usability issue (such as a cosmetic/UX issue or being difficult to understand).
- **Low** - Non-core functionality has a usability issue.

### Suggesting Enhancements
If you found a place where Carpe could improve, create an issue! Feedback is critical to creating a good product,
and that applies to everyone. To submit an enhancement:

- Check if the enhancement has been submitted - similarly to a bug, see if anyone else has proposed the same
improvement you have. If someone already suggested something similar, chime in on their issue with any alternate
ideas to continue the discussion there.
- Create the enhancement issue - If there isn't a similar enhancement submitted yet, create a new issue labeled *enhancement* that describes the improvement you
would like to see. Make sure your issue contains the following:
	 - **A clear title** - describe your enhancement in a few words to lure people in and allow for easy issue browsing.
	 - **A fleshed-out concept** - for other people to act on your idea, describe it in as much detail as you
	can, citing any outside influences that may have inspired you, such as other websites with similar features to
	what you may be requesting. If you are so inclined, mockups, sketches, or system diagrams can help. Screenshots of the
	existing functionality to be enhanced are also useful. Feedback from users who have requested this enhancement
	or who would take value from it are even better.
	- **A value statement** - explain why we should take on this enhancement. Who does it serve, and how does it
	improve the platform overall?

## Creating Pull Requests

Pull requests are how we approve code to go into Carpe's development and production versions. There are three
types of pull requests:

- **Development** - a development PR is work on a feature or a bug fix that is non-critical and will be
deployed with the next scheduled release. Most PRs fall under this category. Development PRs come from a
feature branch and go into the `dev` branch.
	- Merge Requirements:
		- Be tested locally by reviewers
		- Be approved by two team members
- **Deployment** - a deployment PR is one that signifies a deployment of the approved development work done on
Carpe since the last release. These pull requests go from `dev` into `master`.
	- Merge Requirements:
		- Be tested locally and on the [test server](https://carpe-test.herokuapp.com/) by reviewers
		- Be approved by three or more team members, including at least one co-founder (Robert or Viktor)
		- Be open for more than 48 hours
- **Hotfix** - a hotfix PR is a critical bugfix or feature that circumvents the typical deployment process for
the sake of immediate app stability or base functionality. Hotfixes go from a hotfix branch (which **must** be created off of `master`) back
into `master`.
	- Merge Requirements:
		- Be tested locally and on the [test server](https://carpe-test.herokuapp.com/) by reviewers
		- Be approved by two team members, one of which must be a co-founder (Robert or Viktor)

Pull requests going into `master` should be assigned to a co-founder, whose responsibility it is to perform the
final merge and to deploy the changes onto production. This is to prevent changes being merged onto `master` and
then not being deployed.

All pull requests have some formatting requirements:
- **A clear, descriptive title** - this should describe the basics of what the pull request does and should not
contain issue numbers.
- **A thorough, explanatory description** - this should describe the approach taken to solving the problem,
**all** changes made by the pull request, and any anticipated risks for breaking other work. If the change is
primarily visual, you should show GIFs or screenshots of your changes.
- **Links to relevant issues** - all issues being resolved by the pull request should be linked in the
pull request description. *Tip:* You can automatically close issues relating to your PR using certain
[keywords](https://help.github.com/articles/closing-issues-using-keywords/).

## Writing Code for Carpe

### Core Principles
When writing code for Carpe, it's important to keep the following principles in mind:
 - **Readability** - code should be clean, readable, and well-documented to ensure that others can read your work
 and that you can read your work in the (near and far) future.
 - **Reusability** - code should be modular, so that it can be applied to solving more than one problem. Most solutions
 can apply to more than just the problem that necessitated them.
 - **Testability** - code should be testable in an automated fashion via unit, integration, and acceptance tests.
 This makes it so folks working after you can ensure they aren't breaking the functionality you created, and decreases
 the rate at which large errors make it out to production.

# Deploying Carpe

Deploying Carpe should be done carefully and in a planned fashion, as it is a live application that should have relatively guaranteed uptime.
- All releases must go through a one week QA period on a release branch - During this time, no new features are merged in and QA should be done locally and on test Heroku to ensure that all core functionality is working properly.
- All releases must have been frozen for 48 hours prior to the release time - For the 48 hours before a release, QA should be carried out with **absolutely no changes** made to the release candidate. This release lock time allows for a final set of testing that can verify that all functionality is working properly without any risk of new changes breaking it. If critical bugs are found that need to delay deployment, the 48 hour release candidate lock must begin anew when the fix is applied to the release branch, and the full deployment QA process must be rerun.
- Before a deployment (but after making a release candidate), go through all development issues and change them to be labelled release-candidate instead of development, as they are now on the release candidate branch.
- After deployment:
	 - Remove the release-candidate label from any remaining issues, as they are now on production if they have not been resolved.
	 - Open a pull request from `master` into `dev` to get fixes applied to the release-candidate into the development environment.

# Testing Carpe

Before and after deployment, the following manual checks must be made:

- [ ] A user can login to Carpe via a Google account
- [ ] A user can login to Carpe via an email and password
- [ ] A user can view their dashboard with their upcoming events and the availability of users they are following
- [ ] A user can view their schedule
- [ ] A user can create an event
- [ ] A user can edit an existing event
- [ ] A user can view another user's profile

Copy paste this list into the deployment pull request and check off these items during the 48 hour release candidate lock. If the release candidate is changed, uncheck all of these results and rerun these manual tests.

When creating a new issue, make sure to follow the guidelines laid out in the Creating Issues section of this document.

