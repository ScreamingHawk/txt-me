config =
	# The AWS region you would like to use
	awsRegion: "us-east-1"
	# The number to send to. Ensure you use include the country code
	phoneNumber: "+64212530730"
	# Rate limiting
	rateLimit:
		# If you would like to use rate limiting to lower costs
		enabled: true
		# The bucket where you store the rate limit helper file
		bucket: "your_bucket"
		# The file which holds the rate limit helper info
		file: "your_file.txt"
		# The number of messages allowed per month (100 is the free tier limit)
		perMonth: 100


AWS = require "aws-sdk"
AWS.config.update
	region: config.awsRegion

sendTxt = (message, context, done) ->
	# Message max length is 140 characters
	message = message.substring 0, 140
	new AWS.SNS().publish
			Message: message
			PhoneNumber: config.phoneNumber
		, (err)->
			if err?
				errMsg = "Unable to send SMS"
				console.log err
				return done null, createResponse 500, errMsg
			return done null, createResponse 200, "Message sent"

createResponse = (code, message)->
	return
		statusCode: code
		headers:
			"Access-Control-Allow-Origin": "*"
			"Access-Control-*": "*"
		body: JSON.stringify
			message: message

exports.handler = (event, context, done)->
	if event?.body?
		message = JSON.parse event.body
			.message
	else
		message = event?.message
	if !message
		# No message, fail
		errMsg = "No message supplied"
		console.log errMsg
		return done null, createResponse 400, errMsg
	if !config.rateLimit?.enabled
		# No rate limit, just send
		return sendTxt message, context, done

	# Rate limit check
	s3 = new AWS.S3();
	params =
	file = s3.getObject
			Bucket: config.rateLimit.bucket
			Key: config.rateLimit.file
		, (err, data)->
			if err?
				errMsg = "Unable to access rate limit information"
				console.log errMsg
				console.log err
				return done null, createResponse 500, errMsg
			vals = data.Body?.toString().split ":"
			curMonth = "#{new Date().getMonth()}"
			if vals?.length > 1
				month = vals[0]
				count = vals[1]
				if month != curMonth
					# Month rolled over, reset counter
					console.log "New month. Resetting rate"
					month = curMonth
					count = 0
			else
				# First run
				console.log "No rate data. Resetting"
				month = curMonth
				count = 0

			if count >= config.rateLimit.perMonth
				# Rate limit exceeded
				errMsg = "Rate limit of #{config.rateLimit.perMonth} reached"
				console.log errMsg
				return done null, createResponse 429, errMsg

			count++

			s3.putObject
					Bucket: config.rateLimit.bucket
					Key: config.rateLimit.file
					Body: "#{month}:#{count}"
				, (err)->
					if err?
						errMsg = "Unable to update rate limit information"
						console.log errMsg
						console.log err
						return done null, createResponse 500, errMsg
					return sendTxt message, context, done
