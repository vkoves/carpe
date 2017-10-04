# Contributing to Carpe

## Creating Issues

Issues are how we track work to be done on Carpe, including bugs and features.
If you think there's something that needs to get done on Carpe, an issue is how you can start that process.
This part of the contribution guide describes creating issues for bugs and enhancements.

### Reporting Bugs
One of the most common types of issues are bugs. If you find a bug on Carpe, follow these steps:

- Check if the bug has already been reported - a quick search through our open issues should show you if
you are the first person reporting this bug. If someone else has reported the bug, you might want to add
your voice to the conversation to indicate that the issue can be replicated.
- Report the bug - create a new issue with the label *bug* and any other relevant labels. When creating
an issue for a bug make sure to:
	- **Write a clear title** - this makes it easy to sort through issues and find ones that might be more urgent
	or touch certain code.
	- **Describe steps for recreating the bug** - step by step instructions will make it possible for others to
	reproduce the issue and debug it, so the better the instructions, the more likely the problem will get
	solved.
	- **Give an urgency assessment** - at the end of the issue, give your personal assessment of how important this
	issue is. Does the bug make the platform completely unusable? It probably deserves more attention.

### Suggesting Enhancements
If you found a place where Carpe could improve, create an issue! Feedback is critical to creating a good product,
and that applies to everyone. To submit an enhancement:

- Check if the enhancement has been submitted - similarly to a bug, see if anyone else has proposed the same
improvement you have. If someone already suggested something similar, chime in on their issue with your alternate
idea to continue the discussion there.
- Create the enhancement issue - create a new issue labeled *enhancement* that describes the improvement you
would like to see. Make sure your issue contains the following:
	 - **A clear title** - describe your enhancement in a few words to lure people in and allow for easy issue browsing
	 - **A fleshed out concept** - for other people to take action on your idea, describe it in as much detail as you
	can, citing any outside influences that may have inspired you, such as other websites with similar features as
	you may be requesting. If you are so inclined, mockups, sketches, or system diagrams can help. Screenshots of the
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
 - **Readability** - code should be clean, readable, and well documented to ensure that others can read your work
 and that you can read you work far in the future.
 - **Reusability** - code should be modular so that it can be applied to solving more than one problem. Most solutions
 can apply to more than just the problem that necessitated them.
 - **Testability** - code should be testable in an automated fashion via unit, integration, and acceptance tests.
 This makes it so folks working after you can ensure they aren't breaking the functionality you created, and decreases
 the rate at which large errors make it out to production.