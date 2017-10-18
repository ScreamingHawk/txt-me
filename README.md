# Txt Me

A simple service for sending an SMS message to a single number.

# Configure

Modify the configuration values at the top of `server/index.coffee` with your values.

**Note**: The configuration is located in the server code to allow for the use of inline code editing in AWS Lambda.

# Build

```
npm i
coffee -c .
```

# Deploy

Set up an AWS Lambda function with permissions to:

* send SMS messages via AWS SNS
* read and write to the S3 file configured in `server/index.coffee`
* (optional) write to CloudWatch for logging

Configure a AWS API Gateway trigger for the Lambda function.
Ensure CORS is enabled for this endpoint.

Create the S3 bucket configured in `server/index.coffee`.

Create a blank file in the location configured in `server/index.coffee`.

# Test

Change the `apiUrl` in `client/js/txt_me.js` to your API Gateway endpoint.

Open `client/example.html` in your favourite browser.

Submit the form.
