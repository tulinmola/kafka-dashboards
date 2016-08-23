$(() => {
  // Open file selector when clicking in link/submit button
  $(document).on("click", "a[data-file-form]", (event) => {
    const $form = $($(event.target).data("file-form"))
    $form.find("input[type=file]").val("").trigger("click")
    event.preventDefault()
  })
  $(document).on("click", ".file-form input[type=submit]", (event) => {
    const $form = $(event.target).closest("form")
    $form.find("input[type=file]").val("").trigger("click")
    event.preventDefault()
  })

  // Submit form when selecting file
  $(document).on("change", ".file-form input[type=file]", (event) => {
    $(event.target).closest("form").submit()
  })
})
