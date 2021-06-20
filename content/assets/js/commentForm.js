function togglePreviewMathjax(e) {
  e.togglePreview()
  var wrapper = e.codemirror.getWrapperElement()
  p = wrapper.lastChild
  MathJax.typeset([p])
}

var mde = new EasyMDE({
  element: document.getElementById('mensagem'),
  spellChecker: false,
  autosave: {
    enabled: true,
    uniqueId: 'abobringela-' + uuid},
  toolbar: ['bold', 'italic', 'strikethrough', '|',
    'heading-smaller', 'heading-bigger', '|',
    'code', 'quote', 'unordered-list', 'ordered-list', 'link', '|',
    {
      name: 'preview',
      action: togglePreviewMathjax,
      className: 'fa fa-eye',
      noDisable: true,
      title: 'Toggle Preview',
      default: true,
    },
  ],
});

const form = document.getElementById('comment-form');
const ad = document.getElementById('action-description')

function answerComment(ref) {
  if (ad.firstChild) {
    el = ad.firstChild
  } else {
    el = document.createElement("aside")
    ad.appendChild(el)
  }
  n = document.getElementById(ref).querySelector("title").text
  el.innerHTML = "Respondendo a <a href='#" + ref + "'>um comentário feito por " + n + "</a>."
  form.querySelector("#ref-input").value = ref
}

form.addEventListener('submit', e => {
  e.preventDefault();
  const fd = new FormData(form);
  const xhr = new XMLHttpRequest();
  xhr.addEventListener('load', e => {
    alert("Comentário enviado! Agora ele precisa ser aprovado.")
  });
  xhr.addEventListener('error', e => {
    alert("Houve um erro ao enviar o comentário, contate o dono do site.")
    console.log(e);
  });
  xhr.open('POST', form.action);
  xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
  const obj = {};
  [...fd.entries()].forEach(entry => {
      obj[entry[0]] = entry[1];
  });
  const formBody = Object.keys(obj).map(key => encodeURIComponent(key) + '=' + encodeURIComponent(obj[key])).join('&')
  console.log(formBody);
  xhr.send(formBody);
});
