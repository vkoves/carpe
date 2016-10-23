<img src="app/assets/images/pages/JustTheLetter.png?raw=true" width="100" align="right">

# Carpe

A socially networked, intuitive calendar created in Ruby on Rails with a jQuery powered front end.

## Setup
Link to first-time setup can be found in the IndigoBox > Carpe Google Drive directory. 

## Running Locally
Run with foreman using `foreman start`

Which will run the local server at `localhost:5000`

Alternatively `rails s` can be used to the same effect, but the site will be visible at `localhost:3000`

## Testing Carpe

To run all Ruby on Rails tests for Carpe, run `bundle exec rake test` in the Carpe directory.

To run a specific test, run `bundle exec rake test test_file_path`
Ex: `bundle exec rake test test/controllers/event_test.rb`

## Checking Code Quality

At the moment, Carpe uses [Ruby Critic](https://github.com/whitesmith/rubycritic) for code quality checking.

To run Ruby Critic, run `rubycritic` in the Carpe directory.

## Previewing Emails

Although it has not been worked on extensively, Carpe is hooked up to SendGrid and has capabilities to send emails. Rails likewise has support for previewing emails through [Action Mailer Previews](https://github.com/rails/rails/blob/master/guides/source/4_1_release_notes.md#action-mailer-previews). Currently you can view all our emails (currenly only an email sent on signup) by going [here](http://localhost:5000/rails/mailers/user_notifier) if you use Foreman as your local server. Otherwise just change the port as you require.

## Deploying Changes

Make sure to push to origin and then heroku, like so:

``
git push origin master
`` and then
``
git push heroku master
``
