function togglePreviewMathjax(e) {
  e.togglePreview()
  var wrapper = e.codemirror.getWrapperElement()
  p = wrapper.lastChild
  setTimeout(() => { MathJax.typeset([p]) }, 0)
}

function _toggleMath(editor, type, start_chars, end_chars) {
    if (/editor-preview-active/.test(editor.codemirror.getWrapperElement().lastChild.className))
        return;

    end_chars = (typeof end_chars === 'undefined') ? start_chars : end_chars;
    var cm = editor.codemirror;
    var stat = editor.getState(cm);

    var text;
    var start = start_chars;
    var end = end_chars;

    var startPoint = cm.getCursor('start');
    var endPoint = cm.getCursor('end');

    if (stat[type]) {
        text = cm.getLine(startPoint.line);
        start = text.slice(0, startPoint.ch);
        end = text.slice(startPoint.ch);
        if (type == 'inline') {
            start = start.replace(/(\$|\\\()(?![\s\S]*(\$|\\\())/, '');
            end = end.replace(/(\$|\\\))/, '');
        } else if (type == 'display') {
            start = start.replace(/(\$\$|\\\[)(?![\s\S]*(\$\$|\\\[))/, '');
            end = end.replace(/(\$\$|\\\])/, '');
        }
        cm.replaceRange(start + end, {
            line: startPoint.line,
            ch: 0,
        }, {
            line: startPoint.line,
            ch: 99999999999999,
        });

        startPoint.ch -= 1;
        if (startPoint !== endPoint) {
          endPoint.ch -= 1;
        }
    } else {
        text = cm.getSelection();
        if (type == 'inline') {
            text = text.split('\$').join('');
            text = text.split('\\\(').join('');
            text = text.split('\\\)').join('');
        } else if (type == 'display') {
            text = text.split('\$\$').join('');
            text = text.split('\\\[').join('');
            text = text.split('\\\]').join('');
        }
        cm.replaceSelection(start + text + end);

        startPoint.ch += start_chars.length;
        endPoint.ch = startPoint.ch + text.length;
    }

    cm.setSelection(startPoint, endPoint);
    cm.focus();
}

function toggleInlineMath(editor) {
    _toggleMath(editor, 'inline', "\$");
}

function toggleDisplayMath(editor) {
    _toggleMath(editor, 'display', "\$\$");
}


var mde = new EasyMDE({
  element: document.getElementById('mensagem'),
  spellChecker: false,
  autoDownloadFontAwesome: false,
  autosave: {
    enabled: true,
    uniqueId: 'abobringela-' + uuid
  },
  toolbar: ['bold', 'italic', 'strikethrough', '|',
    {
      name: 'inlMath',
      action: toggleInlineMath,
      className: 'fas fa-square-root-alt',
      noDisable: true,
      title: 'Inline math',
      default: true,
    },
    {
      name: 'inlMath',
      action: toggleDisplayMath,
      className: 'fas fa-infinity',
      noDisable: false,
      title: 'Display math',
      default: true,
    },
    '|',
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
