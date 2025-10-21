function notFoundHandler(req, res) {
  res.status(404).json({
    error: 'Not Found',
    message: 'The requested resource does not exist',
  });
}

function globalErrorHandler(err, req, res, next) {
  res.setHeader('X-Content-Type-Options', 'nosniff');

  console.error('[ERROR]', {
    message: err.message,
    stack: process.env.NODE_ENV === 'development' ? err.stack : undefined,
    path: req.path,
    method: req.method,
    ip: req.ip,
  });

  const statusCode = err.statusCode || 500;
  res.status(statusCode).json({
    error: statusCode === 500 ? 'Internal Server Error' : err.message,
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
  });
}

module.exports = { notFoundHandler, globalErrorHandler };
