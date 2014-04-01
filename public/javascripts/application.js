function selectActivity(activity) {
	if (activity.match(/^(erg|run|treadmill|bik|swim|ellip)/i)) {
		if (activity.match(/^erg/i)) {
			jQuery("#distance_row :radio[value=km]").attr("checked", true);
		}
		else {
			jQuery("#distance_row :radio[value=mi]").attr("checked", true);
		}
		jQuery('#time_row').slideDown();
		jQuery('#distance_row').slideDown();
		jQuery('#sets_row').slideUp().find('input').val("");
		jQuery('#weight_row').slideUp().find('input').val("");
		jQuery('#distance_row input:first').focus();
	}
	else {
		jQuery('#time_row').slideUp().find('input').val("");
		jQuery('#distance_row').slideUp().find('input').val("");
		jQuery('#pace_row').slideUp().find('td:last').html("");
		jQuery('#sets_row').slideDown();
		jQuery('#weight_row').slideDown();
		jQuery('#sets_row input:first').focus();
	}
}

function timeToString(time, precision) {
	var hours = Math.floor(time / 3600);
	var minutes = Math.floor(time / 60) % 60;
	var seconds = time % 60;
	var timestring = "";
	if (hours) {
		timestring += hours + ":";
		if (minutes < 10) {
			timestring += "0";
		}
	}
	timestring += minutes + ":";
	if (seconds < 10) {
		timestring += "0";
	}
	timestring += seconds;
	if (precision) {
		var regex = new RegExp("(\\.[0-9]{" + precision + "})[0-9]*");
		timestring = timestring.replace(regex, "$1");
	}
	else {
		timestring = timestring.replace(/\.[0-9]*/, "");
	}
	return timestring;
}

function formatTime(value, axis) {
	return timeToString(value);
}

var METERS_PER_KILOMETER = 1000;
var METERS_PER_MILE = 1609;
function convertDistance(distance, unit, desired_unit) {
	if (unit == desired_unit) {
		return distance;
	}

	switch (unit) {
		case "m":
			if (desired_unit == "km") {
				distance = distance / METERS_PER_KILOMETER;
			}
			else {
				distance = distance / METERS_PER_MILE;
			}
			break;
		case "km":
			distance = distance * METERS_PER_KILOMETER;
			if (desired_unit == "mi") {
				distance = distance / METERS_PER_MILE;
			}
			break;
		case "mi":
			distance = distance * METERS_PER_MILE;
			if (desired_unit = "km") {
				distance = distance * METERS_PER_MILE / METERS_PER_KILOMETER;
			}
			break;
	}

	return distance;
}

function setPace() {
	var activity = jQuery("#activity_row input").val();
	var distance = jQuery("#distance_row input:text").val();
	var unit = jQuery("#distance_row :radio:checked").val();
	var hours = jQuery("#time_row input[name*=hours]").val();
	var minutes = jQuery("#time_row input[name*=minutes]").val();
	var seconds = jQuery("#time_row input[name*=seconds]").val();
	var time = hours * 3600 + minutes * 60 + seconds * 1;

	if (!distance || !time) {
		jQuery("#pace_row").slideUp();
		return;
	}

	var pace;
	var precision = 0;
	var suffix = "/";
	if (activity.match(/^erg/i)) {
		distance = convertDistance(distance, unit, "m");
		pace = time / distance * 500;
		precision = 1;
		suffix += "500m";
	}
	else {
		distance = convertDistance(distance, unit, "mi");
		pace = time / distance;
		suffix += "mi";
	}

	jQuery("#pace_row td:last").html(timeToString(pace, precision) + suffix);
	jQuery("#pace_row").slideDown();
	return;
}

function maxX(data) {
  return maxXY(data, 'x');
}

function maxY(data) {
  return maxXY(data, 'y');
}

function maxXY(data, xy) {
  var max = 0;
  var index = xy == 'x' ? 0 : 1;
  for (point in data) {
    if (data[point][index] > max) {
      max = data[point][index];
    }
  }
  return max;
}

function roundUpToNearest(number, round_to) {
  return Math.floor(number / round_to) * round_to + round_to;
}

function showTooltip(x, y, contents) {
  jQuery('<div id="tooltip">' + contents + '</div>').css({
    position: 'absolute',
    display: 'none',
    top: y + 5,
    left: x + 5,
    border: '1px solid #ddf',
    padding: '2px',
    'background-color': '#eef',
    opacity: 0.80
  }).appendTo("body").fadeIn(200);
}

