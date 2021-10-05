# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_10_05_030057) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assignment_weeks", force: :cascade do |t|
    t.bigint "assignment_id", null: false
    t.float "max_billable_hours"
    t.bigint "iteration_id", null: false
    t.date "week"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["assignment_id"], name: "index_assignment_weeks_on_assignment_id"
    t.index ["iteration_id"], name: "index_assignment_weeks_on_iteration_id"
  end

  create_table "assignments", force: :cascade do |t|
    t.bigint "engagement_id", null: false
    t.bigint "person_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["engagement_id"], name: "index_assignments_on_engagement_id"
    t.index ["person_id"], name: "index_assignments_on_person_id"
  end

  create_table "engagements", force: :cascade do |t|
    t.string "name"
    t.date "starts_on"
    t.date "ends_on"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "iterations", force: :cascade do |t|
    t.date "week"
    t.bigint "engagement_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["engagement_id"], name: "index_iterations_on_engagement_id"
  end

  create_table "people", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "time_entries", force: :cascade do |t|
    t.date "date"
    t.bigint "time_sheet_id", null: false
    t.bigint "assignment_week_id", null: false
    t.float "time_amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["assignment_week_id"], name: "index_time_entries_on_assignment_week_id"
    t.index ["time_sheet_id"], name: "index_time_entries_on_time_sheet_id"
  end

  create_table "time_sheets", force: :cascade do |t|
    t.bigint "person_id", null: false
    t.date "start_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["person_id"], name: "index_time_sheets_on_person_id"
  end

  add_foreign_key "assignment_weeks", "assignments"
  add_foreign_key "assignment_weeks", "iterations"
  add_foreign_key "assignments", "engagements"
  add_foreign_key "assignments", "people"
  add_foreign_key "iterations", "engagements"
  add_foreign_key "time_entries", "assignment_weeks"
  add_foreign_key "time_entries", "time_sheets"
  add_foreign_key "time_sheets", "people"
end
