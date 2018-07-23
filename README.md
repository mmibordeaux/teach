# MMI Bordeaux Teach

[![Maintainability](https://api.codeclimate.com/v1/badges/b856f799521cd84bb132/maintainability)](https://codeclimate.com/github/mmibordeaux/teach/maintainability)

## Google calendar

Do not use repeated events.
In case of ghosts repeated events, use this to delete: 

    https://productforums.google.com/forum/#!msg/calendar/NDpsOwQjzjc/2HfWFgZJpScJ
    https://developers.google.com/apis-explorer/#p/calendar/v3/calendar.events.list
    https://developers.google.com/apis-explorer/#p/calendar/v3/calendar.events.delete

There was a problematic recurring event with id 7p66jnuc3r3ta9rvtlqus22hph_R20180910T140000

## Viz
    https://github.com/mbostock/d3/wiki/Gallery
    http://mlvl.github.io/Hierarchie/#/
    http://bl.ocks.org/kerryrodden/477c1bfb081b783f80ad
    http://www.jasondavies.com/coffee-wheel/

## PPN
    http://src-media.com/ppn-mmi/fiches-modules.html

## DB
    rails g scaffold Semester number:integer
    rails g scaffold TeachingUnit number:integer
    rails g scaffold TeachingSubject label:string teaching_unit_id:integer
    rails g scaffold TeachingCategory label:string
    rails g scaffold TeachingModule code:string label:string objectives:text content:text how_to:text what_next:text hours:integer semester_id:integer teaching_subject_id:integer teaching_unit_id:integer teaching_category_id:integer coefficient:integer
    rails g scaffold Competency label:string teaching_module_id:integer
    rails g scaffold Keyword label:string teaching_module_id:integer

    rails g scaffold Field label:string parent_id:integer
    rails g scaffold Project label:string semester_id:integer
    rails g scaffold User first_name:string last_name:string hours:integer
    rails g scaffold Involvement project_id:integer user_id:integer hours:integer
    rails g scaffold ? project_id:integer teaching_module_id:integer