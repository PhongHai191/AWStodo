const client = require("prom-client");

const register = new client.Registry();
client.collectDefaultMetrics({ register });

const httpRequestsTotal = new client.Counter({
  name: "http_requests_total",
  help: "Total number of HTTP requests",
  labelNames: ["method", "route", "status_code"],
  registers: [register],
});

function metricsMiddleware(req, res, next) {
  res.on("finish", () => {
    // req.baseUrl = "/api/todos", req.route.path = "/:id"  →  "/api/todos/:id"
    const route = req.route
      ? (req.baseUrl + req.route.path).replace(/\/$/, "") || "/"
      : req.path;
    httpRequestsTotal.inc({
      method: req.method,
      route,
      status_code: res.statusCode,
    });
  });
  next();
}

module.exports = { metricsMiddleware, register };
