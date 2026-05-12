<div style="text-align: center;">
    <h2>SIGNERGI / SPQC - Hand Gesture Simulator</h2>
    <video id="webcam" autoplay playsinline width="640" style="border: 5px solid #333; border-radius: 10px;"></video>
    <div id="status-display" style="font-size: 24px; font-weight: bold; color: green; margin-top: 10px;">
        Arahkan tangan (1, 2, 3) dan tekan angka di keyboard
    </div>
</div>

<script>
    // Munculkan Webcam
    navigator.mediaDevices.getUserMedia({ video: true }).then(stream => {
        document.getElementById('webcam').srcObject = stream;
    });

    // Deteksi Keyboard sebagai simulasi Hand Gesture
    document.addEventListener('keydown', function(event) {
        let grade = '';
        if (event.key === '1') grade = '1';
        if (event.key === '2') grade = '2';
        if (event.key === '3') grade = '3';

        if (grade) {
            document.getElementById('status-display').innerText = "Mendeteksi Grade " + grade + "...";
            // Tembak API Laravel yang sudah kita buat tadi
            fetch(`http://10.85.204.5/api/nanas/status?status=${grade}`)
                .then(res => res.json())
                .then(data => {
                    document.getElementById('status-display').innerText = "Tersimpan: " + data.grade;
                });
        }
    });
</script>
