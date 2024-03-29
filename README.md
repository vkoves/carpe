<img src="app/assets/images/pages/CarpeLetter.png?raw=true" width="100" align="right">

# Carpe [![CircleCI](https://circleci.com/gh/vkoves/carpe.svg?style=svg&circle-token=5aac24bfc3b54e541f0d5640d143563f64d97e59)](https://circleci.com/gh/vkoves/carpe)

A socially networked, intuitive calendar created in Ruby on Rails with a jQuery powered front end.

**WARNING :warning:** - This app is no longer maintained as of June 9th, 2019. Feel free to fork it and use it for your own benefit, but it is not receiving new updates. We will likely archive it later on.

## Setup

1) Install the latest versions of [Ruby](https://rvm.io/) and [npm](https://nodejs.org/en/download/)
2) Run `gem install bundler`, `bundle install`, and `npm install`
3) Install [ImageMagick](http://www.imagemagick.org/script/download.php) (It's used for processing uploaded images)

## Running Locally

To run the server locally, run `rails server`. The site will be visible at `localhost:3000`.

## Testing Carpe

Carpe is setup with the default testing suite for Ruby, [Minitest](https://github.com/seattlerb/minitest). All files related to tests are located in the `test` directory, where you can find fixtures (the data used when running tests), and tests for controllers, models, and helpers, as well as integration tests. To get a good overview of how testing in Rails works, see this [RailsGuides guide](http://guides.rubyonrails.org/testing.html) on the subject.

Carpe is also setup with Javascript testing via [Teaspoon](https://github.com/jejacks0n/teaspoon) and acceptance tests via [Capybara](https://github.com/teamcapybara/capybara). We also use [Istanbul](https://github.com/gotwarlost/istanbul) for checking Teaspoon Javascript test code coverage.

The Carpe repository also is setup with CircleCI, which automatically runs builds on push or on a pull request being made. You can see the build status at the top of the README, and can click on it to see build progress and logs.

### Running Ruby Tests

To run all Ruby on Rails tests for Carpe, run `bundle exec rails test` in the Carpe directory. A code coverage report will automatically be created at `<localhost>/coverage/index.html` via the [SimpleCov](https://github.com/colszowka/simplecov) gem.

To run a specific test, run `bundle exec rails test test_file_path`

Ex: `bundle exec rails test test/controllers/event_test.rb`

Run Capybara acceptance/system tests with `rails test:system`

### Running Javascript Tests

To run Teaspoon tests run `npm run teaspoon` from the Carpe directory. This will simultaneously run Teaspoon tests and Istanbul code coverage. You can access teaspoon tests results at `<localhost>/teaspoon/default/`, and Istanbulc code coverage at `<localhost>/coveragejs/default/`.

## Checking Code Quality

### Javascript (ESLint)

Carpe uses [ESLint](https://eslint.org/), which automatically runs as part of our CI. If you want to run it manually, run:

```
npm run eslint
```

To auto-fix issues that ESLint can fix, run:

```
npm run eslint-fix
```

### Ruby

Carpe's Ruby code is linted with [RuboCop](https://github.com/rubocop-hq/rubocop).
Run it by entering `rubocop` in command line, or to auto-fix, run `rubocop --a`.
To see offense counts broken down by file, run `rubocop --format worst`.

### SCSS Linting

Carpe uses [scss-lint](https://github.com/brigade/scss-lint). The rules are explained in the [documentation](https://www.rubydoc.info/github/brigade/scss-lint/master/frames). Custom rules are defined in `.scss-lint.yml`.

Run it by entering `scss-lint` in the command line.

### ERB Lint

Carpe uses [erb_lint](https://github.com/Shopify/erb-lint) to lint HTML ERB files.

Run it on all files by running:

```
bundle exec erblint --lint-all
```

Run it on a folder or specific file by running:

```
bundle exec erblint [file/folder]
```

## JSDoc

Carpe uses JSDoc to document Javascript, which you can learn more about at [JSDoc's Getting Started](http://usejsdoc.org/about-getting-started.html).

Run JSDoc by entering `npm run jsdoc` in command line.

## Checking Site Speed

Carpe uses [rack-mini-profiler](https://github.com/MiniProfiler/rack-mini-profiler) as a way of understanding site speed and optimizing queries. When running Carpe locally, a site speed badge will show up in the top left, allowing you to explore site speed. On production, this badge is hidden by defualt, and can be made visible using *Alt + P*. This shortcut can also be used to hide the profiler when running Carpe locally.

## Previewing Emails

Although it has not been worked on extensively, Carpe is hooked up to SendGrid and has capabilities to send emails. Rails likewise has support for previewing emails through [Action Mailer Previews](https://github.com/rails/rails/blob/master/guides/source/4_1_release_notes.md#action-mailer-previews). Currently you can view all our emails (currently only an email sent on signup) by going to `<localhost>/rails/mailers/user_notifier`.

## Deploying Changes

Before deploying changes, make sure to run the automated tests (see _Testing Carpe_) to make sure nothing is broken.

Then to deploy, push to origin and then Heroku, like so:

``
git push origin master
`` and then
``
git push heroku master
``

This ensures that the repository is never behind the server, preventing overwriting deployed changes.

## Accessing Database

### Local
Locally, Carpe runs off of a database at `db/development.sqlite3`, which is an Sqlite database that you can open using a program called sqliteman. sqliteman is the best way to view and edit the database locally.

### Production
On production, Carpe uses a SQL2 database hosted as a Heroku addon. To access it, you need to install the MySql Workbench, and setup a new connection.

You can find all of the information to connect to the database in the Heroku variable "DATABASE_URL" which is found under Carpe -> Settings -> Config Variables. The DATABASE_URL has the format mysql2://**username**:**password**@**host**/heroku _**appid**?reconnect=true. In SQL Workbench, simply put in the host, username, and password. The default port will work for connecting to the database.

## Contributing

An indigoBox member looking to help out with Carpe, but not sure where to start?

We keep track of everything that needs to be done in the *Issues* section of this GitHub, so head over to see all tasks. Check out our upcoming milestones to find priority changes, or sort by labels like *bug* or *help-wanted* to see where you can assist.
