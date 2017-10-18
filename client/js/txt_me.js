apiUrl = "YOUR_LAMBDA_URL_HERE";

$(document).ready(function(){
	$('#txtForm').submit(function(e){
		e.preventDefault();

		if (apiUrl == "YOUR_LAMBDA_URL_HERE"){
			$('#note').text("You must update the apiUrl in 'client/js/txt_me.js' before using this test page...");
		} else {

			var formData = {
				message: $('#message').val()
			};

			$('#note').removeClass('hidden');
			$('#message').attr('disabled', true);
			$('#sendButton').addClass('hidden');

			$('#note').text("Sending message... Please wait...");

			$.ajax({
				type: 'POST',
				url: apiUrl,
				data: JSON.stringify(formData),
				dataType: 'json'
			}).done(function(data){
				console.log("Message sent");
				console.log(data);
				$('#note').text(JSON.stringify(data));
			}).fail(function(data){
				console.log("Message sent with error");
				console.log(data);
				$('#note').text(JSON.stringify(data));
			});
		}

		return false;
	});
});
