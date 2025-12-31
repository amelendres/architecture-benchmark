done = function(summary, latency, requests)
    sec = summary.duration/1000000

  file = io.open("results/http.json", "w")
  file:write(string.format([[
{
  "p50": %.2f,
  "p95": %.2f,
  "p99": %.2f,
  "rps": %.2f
}
]],
    latency:percentile(50) / 1000,
    latency:percentile(95) / 1000,
    latency:percentile(99) / 1000,
    summary.requests / sec
  ))
  file:close()
end