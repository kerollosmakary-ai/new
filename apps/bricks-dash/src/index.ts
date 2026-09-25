import { serve } from "bun";
import { $ } from "bun";

const PORT = Number(process.env.PORT ?? 8003);
const PHONE_LLM = process.env.PHONE_LLM ?? "http://127.0.0.1:8080";
const TOKEN = process.env.DASH_TOKEN ?? "";   // optional; empty = open

// ---- helpers ---------------------------------------------------------------
const sh = async (cmd: string, fallback = "") => {
  try { return (await $`sh -c ${cmd}`.text()).trim(); }
  catch { return fallback; }
};

const svc = async (unit: string) =>
  (await sh(`systemctl is-active ${unit} 2>/dev/null || true`, "inactive")) || "inactive";

const mem = async () => {
  const m = await sh("cat /proc/meminfo");
  const g = (k: string) => {
    const line = m.split("\n").find(l => l.startsWith(k));
    return line ? Math.round(parseInt(line.split(/\s+/)[1], 10) / 1024) : 0;
  };
  return { totalMB: g("MemTotal"), freeMB: g("MemAvailable") };
};

const disk = async () =>
  await sh(`df -BM / | awk 'NR==2{gsub("M","",$2);gsub("M","",$4);print $4}'`, "0");

const uptime = async () => await sh("cut -d. -f1 /proc/uptime", "0");

const phoneLLM = async () => {
  try {
    const r = await fetch(`${PHONE_LLM}/v1/models`, { signal: AbortSignal.timeout(1500) });
    return r.ok ? "up" : `http ${r.status}`;
  } catch { return "unreachable"; }
};

const requireAuth = (req: Request) => {
  if (!TOKEN) return true;
  const h = req.headers.get("authorization") ?? "";
  const q = new URL(req.url).searchParams.get("token") ?? "";
  return h === `Bearer ${TOKEN}` || q === TOKEN;
};

// ---- routes ----------------------------------------------------------------
serve({
  port: PORT,
  async fetch(req) {
    const url = new URL(req.url);

    if (!requireAuth(req)) return new Response("unauthorized", { status: 401 });

    if (url.pathname === "/api/status") {
      const [units, memv, diskFree, up, phone] = await Promise.all([
        Promise.all(
          ["bricks-dash", "bricks-agent-ui", "bricks-daemon", "caddy", "ssh"]
            .map(async u => ({ unit: u, state: await svc(u) }))
        ),
        mem(),
        disk(),
        uptime(),
        phoneLLM(),
      ]);
      return Response.json({
        host: await sh("hostname"),
        ip: await sh("hostname -I | awk '{print $1}'"),
        uptimeSec: Number(up),
        mem: memv,
        diskFreeMB: Number(diskFree),
        units,
        phoneLLM: phone,
        ts: new Date().toISOString(),
      });
    }

    if (url.pathname === "/api/ask" && req.method === "POST") {
      const body = (await req.json()) as { prompt?: string };
      const prompt = (body.prompt ?? "").slice(0, 2000);
      try {
        const r = await fetch(`${PHONE_LLM}/v1/chat/completions`, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            model: "local",
            messages: [{ role: "user", content: prompt }],
            stream: false,
          }),
          signal: AbortSignal.timeout(30_000),
        });
        if (!r.ok) return Response.json({ error: `phone LLM ${r.status}` }, { status: 502 });
        const j = await r.json();
        return Response.json({ reply: j.choices?.[0]?.message?.content ?? "" });
      } catch (e) {
        return Response.json({ error: String(e) }, { status: 502 });
      }
    }

    if (url.pathname === "/") {
      return new Response(HTML, { headers: { "Content-Type": "text/html; charset=utf-8" } });
    }

    return new Response("not found", { status: 404 });
  },
});

console.log(`[bricks-dash] http://0.0.0.0:${PORT}`);

// ---- inline HTML (Tailwind CDN, no build step) -----------------------------
const HTML = String.raw`<!doctype html>
<html lang="en" class="h-full bg-slate-950 text-slate-100">
<head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>BRICKS Dash</title>
<script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="min-h-screen p-6 font-mono">
<div class="max-w-4xl mx-auto space-y-6">

  <header class="flex items-center justify-between border-b border-slate-800 pb-4">
    <h1 class="text-2xl font-bold">BRICKS <span class="text-pink-400">Dash</span></h1>
    <span id="ts" class="text-xs text-slate-500"></span>
  </header>

  <section class="grid grid-cols-2 md:grid-cols-4 gap-3">
    <div class="bg-slate-900 border border-slate-800 rounded-lg p-4">
      <div class="text-xs text-slate-500">HOST</div>
      <div id="host" class="text-lg font-bold">—</div>
      <div id="ip" class="text-xs text-slate-500">—</div>
    </div>
    <div class="bg-slate-900 border border-slate-800 rounded-lg p-4">
      <div class="text-xs text-slate-500">UPTIME</div>
      <div id="uptime" class="text-lg font-bold text-cyan-400">—</div>
    </div>
    <div class="bg-slate-900 border border-slate-800 rounded-lg p-4">
      <div class="text-xs text-slate-500">MEM</div>
      <div id="mem" class="text-lg font-bold text-amber-400">—</div>
    </div>
    <div class="bg-slate-900 border border-slate-800 rounded-lg p-4">
      <div class="text-xs text-slate-500">DISK FREE</div>
      <div id="disk" class="text-lg font-bold text-emerald-400">—</div>
    </div>
  </section>

  <section class="bg-slate-900 border border-slate-800 rounded-lg p-4">
    <div class="text-xs text-slate-500 mb-2">SYSTEMD UNITS</div>
    <div id="units" class="space-y-1 text-sm"></div>
  </section>

  <section class="bg-slate-900 border border-slate-800 rounded-lg p-4">
    <div class="flex items-center justify-between mb-2">
      <div class="text-xs text-slate-500">PHONE LLM</div>
      <span id="phone" class="text-xs">—</span>
    </div>
    <textarea id="prompt" placeholder="ask the phone…"
      class="w-full bg-slate-950 border border-slate-800 rounded p-3 text-sm h-20"></textarea>
    <button onclick="ask()" class="mt-2 bg-pink-600 hover:bg-pink-500 px-4 py-2 rounded text-sm font-bold">Ask</button>
    <pre id="reply" class="mt-3 text-sm text-slate-300 whitespace-pre-wrap"></pre>
  </section>

</div>

<script>
const $ = s => document.querySelector(s);
const fmtUptime = s => {
  const d = Math.floor(s/86400), h = Math.floor(s%86400/3600), m = Math.floor(s%3600/60);
  return (d?d+"d ":"") + (h?h+"h ":"") + m + "m";
};
const tok = new URL(location).searchParams.get("token");
const qs = tok ? "?token="+tok : "";

async function refresh() {
  try {
    const d = await (await fetch("/api/status"+qs)).json();
    $("#host").textContent = d.host;
    $("#ip").textContent = d.ip;
    $("#uptime").textContent = fmtUptime(d.uptimeSec);
    $("#mem").textContent = (d.mem.freeMB/1024).toFixed(1)+" / "+(d.mem.totalMB/1024).toFixed(1)+" GB";
    $("#disk").textContent = (d.diskFreeMB/1024).toFixed(1)+" GB";
    $("#ts").textContent = d.ts;

    const pc = d.phoneLLM === "up" ? "text-emerald-400" : "text-red-400";
    $("#phone").className = "text-xs " + pc;
    $("#phone").textContent = d.phoneLLM;

    $("#units").innerHTML = d.units.map(u => {
      const ok = u.state === "active";
      return '<div class="flex justify-between">'
        + '<span>'+u.unit+'</span>'
        + '<span class="'+(ok?"text-emerald-400":"text-red-400")+'">'+u.state+'</span>'
        + '</div>';
    }).join("");
  } catch (e) {
    $("#ts").textContent = "error: " + e;
  }
}

async function ask() {
  const p = $("#prompt").value.trim();
  if (!p) return;
  $("#reply").textContent = "…";
  try {
    const r = await fetch("/api/ask"+qs, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ prompt: p })
    });
    const j = await r.json();
    $("#reply").textContent = j.reply ?? j.error ?? "?";
  } catch (e) {
    $("#reply").textContent = "error: " + e;
  }
}

refresh();
setInterval(refresh, 5000);
</script>
</body>
</html>`;
