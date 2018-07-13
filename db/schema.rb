# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180713091504) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "competencies", force: :cascade do |t|
    t.string   "label"
    t.integer  "teaching_module_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "events", force: :cascade do |t|
    t.date     "date"
    t.float    "duration"
    t.integer  "teaching_module_id"
    t.integer  "promotion_id"
    t.integer  "kind"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.float    "student_hours"
    t.float    "teacher_hours"
  end

  add_index "events", ["promotion_id"], name: "index_events_on_promotion_id", using: :btree
  add_index "events", ["teaching_module_id"], name: "index_events_on_teaching_module_id", using: :btree

  create_table "events_users", id: false, force: :cascade do |t|
    t.integer "event_id", null: false
    t.integer "user_id",  null: false
  end

  add_index "events_users", ["event_id", "user_id"], name: "index_events_users_on_event_id_and_user_id", using: :btree

  create_table "fields", force: :cascade do |t|
    t.string   "label"
    t.integer  "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "position"
    t.string   "color"
  end

  create_table "fields_jobs", force: :cascade do |t|
    t.integer  "field_id"
    t.integer  "job_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fields_projects", force: :cascade do |t|
    t.integer  "field_id"
    t.integer  "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fields_teaching_modules", force: :cascade do |t|
    t.integer "field_id"
    t.integer "teaching_module_id"
  end

  create_table "fields_users", force: :cascade do |t|
    t.integer "field_id"
    t.integer "user_id"
  end

  create_table "involvements", force: :cascade do |t|
    t.integer  "teaching_module_id"
    t.integer  "user_id"
    t.integer  "hours_cm",           default: 0
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.text     "description"
    t.integer  "hours_td",           default: 0
    t.integer  "hours_tp",           default: 0
    t.integer  "multiplier_td",      default: 2
    t.integer  "multiplier_tp",      default: 3
    t.integer  "groups_tp",          default: 3
    t.integer  "project_id"
    t.integer  "promotion_id"
    t.float    "teacher_hours_cm",   default: 0.0, null: false
    t.float    "teacher_hours_td",   default: 0.0, null: false
    t.float    "teacher_hours_tp",   default: 0.0, null: false
    t.float    "teacher_hours",      default: 0.0, null: false
    t.float    "student_hours_cm",   default: 0.0, null: false
    t.float    "student_hours_td",   default: 0.0, null: false
    t.float    "student_hours_tp",   default: 0.0, null: false
    t.float    "student_hours",      default: 0.0, null: false
  end

  add_index "involvements", ["promotion_id"], name: "index_involvements_on_promotion_id", using: :btree

  create_table "jobs", force: :cascade do |t|
    t.string   "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "keywords", force: :cascade do |t|
    t.string   "label"
    t.integer  "teaching_module_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "objectives", force: :cascade do |t|
    t.string   "label"
    t.integer  "teaching_module_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "objectives_projects", id: false, force: :cascade do |t|
    t.integer "objective_id", null: false
    t.integer "project_id",   null: false
  end

  add_index "objectives_projects", ["objective_id", "project_id"], name: "index_objectives_projects_on_objective_id_and_project_id", using: :btree
  add_index "objectives_projects", ["project_id", "objective_id"], name: "index_objectives_projects_on_project_id_and_objective_id", using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "label"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.text     "description"
    t.integer  "position"
    t.integer  "user_id"
    t.integer  "year_id"
    t.text     "detailed_description"
    t.string   "sublabel"
  end

  add_index "projects", ["year_id"], name: "index_projects_on_year_id", using: :btree

  create_table "projects_semesters", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "semester_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "projects_users", force: :cascade do |t|
    t.integer "project_id"
    t.integer "user_id"
  end

  create_table "promotions", force: :cascade do |t|
    t.integer  "year"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "calendar_url"
  end

  create_table "semesters", force: :cascade do |t|
    t.integer  "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "teaching_categories", force: :cascade do |t|
    t.string   "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "teaching_modules", force: :cascade do |t|
    t.string   "code"
    t.string   "label"
    t.text     "content"
    t.text     "how_to"
    t.text     "what_next"
    t.integer  "hours"
    t.integer  "semester_id"
    t.integer  "teaching_subject_id"
    t.integer  "teaching_unit_id"
    t.integer  "teaching_category_id"
    t.integer  "coefficient"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "user_id"
    t.integer  "hours_cm"
    t.integer  "hours_td"
    t.integer  "hours_tp"
    t.string   "code_apogee"
  end

  create_table "teaching_subjects", force: :cascade do |t|
    t.string   "label"
    t.integer  "teaching_unit_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "teaching_units", force: :cascade do |t|
    t.integer  "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "hours"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "tenured"
    t.boolean  "public"
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.boolean  "admin",                  default: false, null: false
  end

  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "years", force: :cascade do |t|
    t.integer  "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "events", "promotions"
  add_foreign_key "events", "teaching_modules"
  add_foreign_key "involvements", "promotions"
  add_foreign_key "projects", "years"
end
