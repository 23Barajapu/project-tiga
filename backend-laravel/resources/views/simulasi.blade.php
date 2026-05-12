<!DOCTYPE html>
<html>
<head>
    <title>SPQC - Control Panel</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body { font-family: 'Segoe UI', sans-serif; text-align: center; background: #0f0f0f; color: white; height: 100vh; display: flex; align-items: center; justify-content: center; margin: 0; }
        .card { background: #1a1a1a; padding: 40px; border-radius: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.5); border: 1px solid #333; width: 90%; max-width: 500px; }
        h1 { color: #00ff41; margin-bottom: 10px; font-size: 24px; letter-spacing: 2px; }
        p { color: #888; margin-bottom: 30px; }

        .btn-container { display: flex; flex-direction: column; gap: 15px; }
        .btn {
            padding: 20px; font-size: 18px; font-weight: bold; border: none; border-radius: 12px; cursor: pointer;
            transition: 0.3s; text-transform: uppercase; letter-spacing: 1px;
        }
        .grade-a { background: #00ff41; color: #000; }
        .grade-b { background: #ffcc00; color: #000; }
        .grade-c { background: #ff3300; color: #fff; }

        .btn:hover { transform: translateY(-3px); filter: brightness(1.2); box-shadow: 0 5px 15px rgba(255,255,255,0.1); }
        .btn:active { transform: translateY(0); }

        #log { margin-top: 30px; padding: 15px; background: #000; border-radius: 8px; font-family: monospace; color: #00ff41; border: 1px solid #222; min-height: 20px; }
    </style>
</head>
<body>
    <div class="card">
        <h1>SPQC CONTROL CENTER</h1>
        <p>Pilih Grade Nanas untuk Dikirim ke Sistem</p>

        <div class="btn-container">
            <button class="btn grade-a" onclick="sendData(1)">GRADE A (MATANG)</button>
            <button class="btn grade-b" onclick="sendData(2)">GRADE B (SETENGAH)</button>
            <button class="btn grade-c" onclick="sendData(3)">GRADE C (MENTAH)</button>
        </div>

        <div id="log">STATUS: READY</div>
    </div>

    <script>
        const logDiv = document.getElementById('log');
        const baseUrl = ""; // Kosongkan saja agar otomatis mengikuti alamat yang sedang dibuka

        function sendData(grade) {
            const labels = {1: 'MATANG', 2: 'SETENGAH', 3: 'MENTAH'};
            logDiv.innerText = "SENDING GRADE " + grade + "...";
            logDiv.style.color = "#ffcc00";

    // Hapus ${baseUrl} agar menjadi relative path
            fetch(`/api/nanas/status?status=${grade}`)
                .then(res => res.json())
                .then(data => {
                    logDiv.innerText = "SUCCESS: " + labels[grade] + " SENT";
                    logDiv.style.color = "#00ff41";
                    setTimeout(() => {
                        logDiv.innerText = "STATUS: READY";
                        logDiv.style.color = "#00ff41";
                    }, 3000);
                })
                .catch(err => {
                    logDiv.innerText = "ERROR: CHECK CONNECTION";
                    logDiv.style.color = "#ff3300";
                });
        }
    </script>
</body>
</html>
