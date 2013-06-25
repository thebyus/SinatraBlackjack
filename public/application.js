$(document).ready(function() {
	$(document).on("click", "form#hit_form input", function() {
		alert("Player Hits!");
		$.ajax({
			type: 'POST',
			url: '/game/player/hit'
		}).done(function(msg) {
			$("#game").replaceWith(msg);
		});
		return false;
	});

	$(document).on("click", "form#stay_form input", function() {
		alert("Player Stays!");
		$.ajax({
			type: 'POST',
			url: '/game/player/stay'
		}).done(function(msg) {
			$("#game").replaceWith(msg);
		});
		return false;
	});

	$(document).on("click", "form#dealer_hit input", function() {
		alert("Dealer Hits!")
		$.ajax({
			type: 'POST',
			url: '/game/dealer/hit'
		}).done(function(msg) {
			$("#game").replaceWith(msg);
		});
		return false;
	});
});

