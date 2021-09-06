document.addEventListener('keydown', (event) => {
  const keyName = event.key;

  if (keyName === 'ArrowLeft') {
    document.querySelector("[data-navigation='previous']").click();
  } else if (keyName === 'ArrowRight') {
    document.querySelector("[data-navigation='next']").click();
  }
}, false);
