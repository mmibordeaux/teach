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

ActiveRecord::Schema.define(version: 20150328162435) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "competencies", force: :cascade do |t|
    t.string   "label"
    t.integer  "teaching_module_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

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

  create_table "involvements", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.integer  "hours"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

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

  create_table "models", force: :cascade do |t|
    t.string   "FieldsJob"
    t.integer  "field_id"
    t.integer  "job_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "objectives", force: :cascade do |t|
    t.string   "label"
    t.integer  "teaching_module_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "projects", force: :cascade do |t|
    t.string   "label"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.text     "description"
  end

  create_table "projects_semesters", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "semester_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "projects_teaching_modules", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "teaching_module_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean  "tenured"
  end

end
