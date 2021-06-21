ex2 = false

document.addEventListener("DOMContentLoaded", function() {
        document.getElementById("extra1").addEventListener('click', function(e) {
                e.preventDefault()
                var i, s, ss = ['/kh.js', 'https://ajax.googleapis.com/ajax/libs/jquery/1.5.1/jquery.min.js'];
                for (i = 0; i != ss.length; i++) {
                        s = document.createElement('script');
                        s.src = ss[i]; document.body.appendChild(s);
                }
        })
        document.getElementById("extra2").addEventListener('click', function(e) {
                e.preventDefault()
                if (ex2) return
                ex2 = true
                var s
                s = document.createElement('script')
                s.src = '/paper-full.min.js'
                document.head.appendChild(s)
                s = document.createElement('script')
                s.src = '/myDrawing.js'
                s['type'] = 'text/paperscript'
                s.setAttribute('canvas', 'fundo')
                document.head.appendChild(s)
        })
})
