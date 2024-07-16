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

ActiveRecord::Schema.define(version: 2021_06_23_071304) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "competencies", id: :serial, force: :cascade do |t|
    t.string "label"
    t.integer "teaching_module_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "events", id: :serial, force: :cascade do |t|
    t.datetime "date"
    t.float "duration"
    t.integer "teaching_module_id"
    t.integer "promotion_id"
    t.integer "kind"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "student_hours"
    t.float "teacher_hours"
    t.string "label"
    t.text "description"
    t.integer "project_id"
    t.bigint "user_id"
    t.bigint "resource_id"
    t.index ["project_id"], name: "index_events_on_project_id"
    t.index ["promotion_id"], name: "index_events_on_promotion_id"
    t.index ["resource_id"], name: "index_events_on_resource_id"
    t.index ["teaching_module_id"], name: "index_events_on_teaching_module_id"
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "fields", id: :serial, force: :cascade do |t|
    t.string "label"
    t.integer "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.string "color"
  end

  create_table "fields_jobs", id: :serial, force: :cascade do |t|
    t.integer "field_id"
    t.integer "job_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fields_projects", id: :serial, force: :cascade do |t|
    t.integer "field_id"
    t.integer "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fields_teaching_modules", id: :serial, force: :cascade do |t|
    t.integer "field_id"
    t.integer "teaching_module_id"
  end

  create_table "fields_users", id: :serial, force: :cascade do |t|
    t.integer "field_id"
    t.integer "user_id"
  end

  create_table "involvements", id: :serial, force: :cascade do |t|
    t.integer "teaching_module_id"
    t.integer "user_id"
    t.float "hours_cm", default: 0.0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.float "hours_td", default: 0.0, null: false
    t.float "hours_tp", default: 0.0, null: false
    t.integer "multiplier_td", default: 2
    t.integer "multiplier_tp", default: 3
    t.integer "groups_tp", default: 3
    t.integer "project_id"
    t.integer "promotion_id"
    t.float "teacher_hours_cm", default: 0.0, null: false
    t.float "teacher_hours_td", default: 0.0, null: false
    t.float "teacher_hours_tp", default: 0.0, null: false
    t.float "teacher_hours", default: 0.0, null: false
    t.float "student_hours_cm", default: 0.0, null: false
    t.float "student_hours_td", default: 0.0, null: false
    t.float "student_hours_tp", default: 0.0, null: false
    t.float "student_hours", default: 0.0, null: false
    t.bigint "resource_id"
    t.index ["promotion_id"], name: "index_involvements_on_promotion_id"
    t.index ["resource_id"], name: "index_involvements_on_resource_id"
  end

  create_table "jobs", id: :serial, force: :cascade do |t|
    t.string "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "keywords", id: :serial, force: :cascade do |t|
    t.string "label"
    t.integer "teaching_module_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "objectives", id: :serial, force: :cascade do |t|
    t.string "label"
    t.integer "teaching_module_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "objectives_projects", id: false, force: :cascade do |t|
    t.integer "objective_id", null: false
    t.integer "project_id", null: false
    t.index ["objective_id", "project_id"], name: "index_objectives_projects_on_objective_id_and_project_id"
    t.index ["project_id", "objective_id"], name: "index_objectives_projects_on_project_id_and_objective_id"
  end

  create_table "projects", id: :serial, force: :cascade do |t|
    t.string "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.integer "position"
    t.integer "user_id"
    t.integer "year_id"
    t.text "detailed_description"
    t.string "sublabel"
    t.date "from"
    t.date "to"
    t.index ["year_id"], name: "index_projects_on_year_id"
  end

  create_table "projects_semesters", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.integer "semester_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "projects_users", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.integer "user_id"
  end

  create_table "promotions", id: :serial, force: :cascade do |t|
    t.integer "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "calendar_url"
  end

  create_table "resources", force: :cascade do |t|
    t.string "label"
    t.string "code"
    t.text "description"
    t.integer "hours_cm", default: 0, null: false
    t.integer "hours_tp", default: 0, null: false
    t.string "code_apogee"
    t.bigint "semester_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["semester_id"], name: "index_resources_on_semester_id"
  end

  create_table "semesters", id: :serial, force: :cascade do |t|
    t.integer "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "teaching_categories", id: :serial, force: :cascade do |t|
    t.string "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "teaching_modules", id: :serial, force: :cascade do |t|
    t.string "code"
    t.string "label"
    t.text "content"
    t.text "how_to"
    t.text "what_next"
    t.integer "hours"
    t.integer "semester_id"
    t.integer "teaching_subject_id"
    t.integer "teaching_unit_id"
    t.integer "teaching_category_id"
    t.integer "coefficient"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "hours_cm"
    t.integer "hours_td"
    t.integer "hours_tp"
    t.string "code_apogee"
  end

  create_table "teaching_subjects", id: :serial, force: :cascade do |t|
    t.string "label"
    t.integer "teaching_unit_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "teaching_units", id: :serial, force: :cascade do |t|
    t.integer "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.integer "hours"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "tenured"
    t.boolean "public"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.boolean "admin", default: false, null: false
    t.string "email_secondary"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "years", id: :serial, force: :cascade do |t|
    t.integer "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "events", "projects"
  add_foreign_key "events", "promotions"
  add_foreign_key "events", "teaching_modules"
  add_foreign_key "events", "users"
  add_foreign_key "involvements", "promotions"
  add_foreign_key "projects", "years"
  add_foreign_key "resources", "semesters"
end
