document.addEventListener("DOMContentLoaded", function(){
  document.getElementById("extra2").addEventListener('click', function(e) {
    e.preventDefault();
    var s;
    s = document.createElement('script');
    s.src = '/js/paper-full.min.js';
    document.head.appendChild(s);
    s = document.createElement('script');
    s.src = '/js/myDrawing.js';
    s['type'] = 'text/paperscript';
    s.setAttribute('canvas', 'fundo');
    document.head.appendChild(s);
  });
});
