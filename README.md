<img src="app/assets/images/pages/CarpeLetter.png?raw=true" width="100" align="right">

# Carpe [![Build Status](https://travis-ci.com/vkoves/carpe.svg?token=Wt2br9iC8tszQJNifjNG&branch=master)](https://travis-ci.com/vkoves/carpe)

A socially networked, intuitive calendar created in Ruby on Rails with a jQuery powered front end.

## Setup
Link to first-time setup can be found in the IndigoBox > Carpe Google Drive directory.

A brief summary:
- Install Ruby on Rails using RVM
- Bundle Install
- Install PhantomJS and Istanbul for Javascript testing
	- Run `npm install -g phantomjs` and `npm install -g istanbul`

## Running Locally
Run with foreman using `foreman start`

Which will run the local server at `localhost:5000`

Alternatively `rails s` can be used to the same effect, but the site will be visible at `localhost:3000`.

Since you can run Carpe with either foreman or the default Rails server, all localhost links in this document use `<localhost>` to stand in for either `localhost:3000` or `localhost:5000`.

## Testing Carpe

Carpe is setup with the default testing suite for Ruby, [Minitest](https://github.com/seattlerb/minitest). All files related to tests are located in the `test` directory, where you can find fixtures (the data used when running tests), and tests for controllers, models, and helpers, as well as integration tests. To get a good overview of how testing in Rails works, see this [RailsGuides guide](http://guides.rubyonrails.org/testing.html) on the subject.

Carpe is also setup with Javascript testing via [Teaspoon](https://github.com/jejacks0n/teaspoon) and acceptance tests via [CodeceptJS](http://codecept.io/). We also use [Istanbul](https://github.com/gotwarlost/istanbul) for checking Teaspoon Javascript test code coverage.

The Carpe repository also is setup with Travis CI, which automatically runs builds on push or on a pull request being made. You can see the build status at the top of the README, and can click on it to see build progress and logs.

### Running Ruby Tests

To run all Ruby on Rails tests for Carpe, use the local admin panel or run `bundle exec rails test` in the Carpe directory.

To run a specific test, run `bundle exec rails test test_file_path`

Ex: `bundle exec rails test test/controllers/event_test.rb`

#### Checking Test Coverage

A large part of making sure Carpe is well tested is ensuring that it has proper test coverage. Carpe uses the [SimpleCov gem](https://github.com/colszowka/simplecov) to help with this. To use SimpleCov, simply run all tests (either via the local admin panel, or manually) and then go to `<localhost>/coverage/index.html`.

### Running Javascript Tests

To run Teaspoon tests on carpe, either use the local admin panel or run `bundle exec teaspoon --coverage=default` from the Carpe directory. This will simultaneously run Teaspoon tests and  Istanbul code coverage. You can access teaspoon tests results at '<localhost>/teaspoon/default', and Istanbulc code coverage at `<localhost>/coveragejs/default/`.

### Running CodeceptJS Acceptance Tests

CodeceptJS lets us run lovely acceptance tests. Run them from the local admin panel or manually by running `codeceptjs run --reporter mochawesome` optionally with `--steps` for extra info. HTML reports of the results will be available at `<localhost>/codeceptjs_out/mochawesome.html`.

## Checking Code Quality

At the moment, Carpe uses [Ruby Critic](https://github.com/whitesmith/rubycritic) for code quality checking.

To run Ruby Critic, run `rubycritic` in the Carpe directory.

## JSDoc

Carpe uses JSDoc to document Javascript, which you can learn more about at [JSDoc's Getting Started](http://usejsdoc.org/about-getting-started.html).

You can run JSDoc from the local admin panel or by running `jsdoc app/assets/javascripts -r README.md -d public/jsdoc-out` in command line.

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
