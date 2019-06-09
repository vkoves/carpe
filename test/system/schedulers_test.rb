require "application_system_test_case"

class SchedulersTest < ApplicationSystemTestCase
  def setup
    sign_in "viktorsemail@example.com", "trombone321"
    visit "/schedule"
  end

  #----------------------------------------------------------------------------
  # Scheduler
  #----------------------------------------------------------------------------

  test "show scheduler" do
    assert_current_path "/schedule"
    assert_selector "#sch-main"
  end

  #----------------------------------------------------------------------------
  # Categories
  #----------------------------------------------------------------------------

  test "create category" do
    click ".cat-add"
    assert_selector ".color-swatch.grey.selected"

    click ".color-swatch.blue"
    assert_selector ".color-swatch.blue.selected"

    type "Random Stuff", into: ".cat-overlay-title"
    click ".sch-evnt-save-cat"

    assert_no_selector ".ui-widget-overlay"
    assert_text "Random Stuff"
    assert_includes categories.last["style"], "rgb(66, 133, 245)"
  end

  # TODO: edit a category with events (and make sure the events are affected)
  test "edit category" do
    click categories.first.find(".sch-evnt-edit-cat")
    type "Family Dinner", into: ".cat-overlay-title"
    click ".sch-evnt-save-cat"

    assert_no_selector ".ui-widget-overlay"
    within(categories.first) { assert_text "Family Dinner" }
  end

  # TODO: delete a category with events (and make sure its events get deleted)
  test "delete category" do
    id = categories.first["data-id"]

    click categories.first.find(".sch-evnt-del-cat")
    within("#overlay-confirm") { click_text "OK" }

    assert_no_selector ".ui-widget-overlay"
    assert_no_selector ".category[data-id='#{id}']"
  end

  # #----------------------------------------------------------------------------
  # # Events
  # #----------------------------------------------------------------------------
  #
  # test "create event" do
  #
  # end
  #
  # test "edit event" do
  #
  # end
  #
  # test "delete event" do
  #
  # end
  #
  # #----------------------------------------------------------------------------
  # # Breaks
  # #----------------------------------------------------------------------------
  #
  # test "create break" do
  #
  # end
  #
  # test "edit break" do
  #
  # end
  #
  # test "delete break" do
  #
  # end
  #
  # test "add break to category" do
  #
  # end
  #
  # test "add break to event" do
  #
  # end

  private

  def categories
    all("#sch-tiles .category:not([id='cat-template'])")
  end
end
