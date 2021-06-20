ex2 = false

document.addEventListener("DOMContentLoaded", function(){
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
