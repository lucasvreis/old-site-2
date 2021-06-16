const form = document.getElementById('comment-form');
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
