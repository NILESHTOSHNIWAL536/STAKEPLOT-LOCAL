// const express = require('express');
// const fs = require('fs');
// const swaggerJsdoc = require('swagger-jsdoc');
// const swaggerUi = require('swagger-ui-express');

// const app = express();

// // Swagger definition options
// const options = {
//   swaggerDefinition: {
//     info: {
//       title: "Your API Documentation",
//       version: "1.0.0",
//       description: "Documentation for your API",
//     },
//     basePath: "/api/v1" // Optional base path of your API
//   },
//   apis: ['./routes/v1/*.js'], // Your route files where JSDoc comments exist
// };

// // Generate swagger specification
// const specs = swaggerJsdoc(options);

// // Write swagger.json file to disk
// fs.writeFileSync('./swagger.json', JSON.stringify(specs, null, 2));

// // Serve swagger UI at /api-docs route
// app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(specs));

// const port = process.env.PORT || 3000;
// app.listen(port, () => {
//   console.log(`Server listening at http://localhost:${port}`);
//   console.log(`Swagger UI available at http://localhost:${port}/api-docs`);
// });
