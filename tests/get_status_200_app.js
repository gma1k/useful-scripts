// Require the express module
const express = require('express');

// Create a new express app
const app = express();

// Define a route for GET requests
app.get('/', (req, res) => {
  // Send a 200 status code and a message
  res.status(200).send('Status check 200: You have a bright future ahead!');
});

// Listen on port 3000
app.listen(3000, () => {
  console.log('App is running on port 3000: Great, and you think its faster than Usain Bolt. xD ');
});
