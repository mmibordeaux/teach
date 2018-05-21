//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require d3
//= require highcharts
//= require highcharts/highcharts-more
//= require chartkick
//= require sunburst
//= require timeline/timeline-min
//= require_self

jQuery(function() {
  $("a[rel~=popover], .has-popover").popover();
  $("a[rel~=tooltip], .has-tooltip").tooltip();
});