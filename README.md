# mmibordeaux

## Viz
    https://github.com/mbostock/d3/wiki/Gallery
    http://mlvl.github.io/Hierarchie/#/
    http://bl.ocks.org/kerryrodden/477c1bfb081b783f80ad
    http://www.jasondavies.com/coffee-wheel/

## PPN
    http://src-media.com/ppn-mmi/fiches-modules.html

## DB
    rails g scaffold Semester number:int
    rails g scaffold TeachingUnit number:int
    rails g scaffold TeachingSubject label:int teaching_unit_id:int
    rails g scaffold TeachingModule code:string label:string objectives:text content:text hours:int semester_id:int teaching_subject_id:int teaching_unit_id:int
    rails g scaffold Competency label:string teaching_module_id:int
    rails g scaffold Keyword label:string teaching_module_id:int

    rails g scaffold Field label:string
    rails g scaffold Project label:string semester_id:int
    rails g scaffold User first_name:string last_name:string hours:int
    rails g scaffold Involvement project_id:int user_id:int hours:int
    rails g scaffold ? project_id:int teaching_module_id:int