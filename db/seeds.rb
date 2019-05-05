# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

for i in 1..5
  User.create name: "test#{i}",
              email: "test#{i}@yahoo.com",
              password: "testing123",
              admin: true,
              confirmed_at: Time.now
end

test1 = User.find_by(name: "test1")
test2 = User.find_by(name: "test2")

category = Category.create(
  name: "Sad Times",
  user: test1,
  privacy: "public"
)

event = Event.create(
  name: "Chores",
  date: Time.parse('30th Oct 2018 4:00:00 PM'),
  end_date: Time.parse('30th Oct 2018 5:00:00 PM'),
  repeat: 'daily',
  user: test1,
  category: category
)

event.make_host_event!

EventInvite.create(
  sender: test1,
  user: test2,
  host_event: event
)
