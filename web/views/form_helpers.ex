defmodule Kdb.FormHelpers do
  @moduledoc """
  Conveniences for form fields.
  """

  use Phoenix.HTML
  import Phoenix.HTML.Form
  import Kdb.ErrorHelpers

  def form_submit(is_creating) do
    text = if is_creating, do: "Create", else: "Update"
    submit(text)
  end

  defp errors_for(form, field) do
    # TODO: This ugly code is to avoid an extrange bug with forms. I'm sure
    # it's not a real bug but an use error from myself. It'd be worth to
    # take a look and try to find the correct – and beautiful – way.
    if Map.has_key?(form.source, :changes) && !Enum.empty?(form.source.changes)
       && form.source.errors[field] do
      form.source.errors[field]
    else
      # Note this is supposed to be the correct way...
      form.errors[field]
    end
  end

  def field(form, function, name, options) do
    klass = "field"
    # error = !Enum.empty?(form.source.changes) && form.source.errors[name]
    label = label(form, name)

    error = errors_for(form, name)
    {klass, error_tag} = if error do
      {
        "#{klass} field-with-errors",
        content_tag(:span, translate_error(error), class: "field-error")
      }
    else
      {klass, nil}
    end

    content_tag :div, class: klass do
      [label, (function.(form, name, options)), error_tag]
      |> Enum.filter(&(&1))
    end
  end

  def email_input_field(f, name, options \\ []) do
    field(f, &email_input/3, name, options)
  end

  def text_input_field(f, name, options \\ []) do
    field(f, &text_input/3, name, options)
  end

  def password_input_field(f, name, options \\ []) do
    field(f, &password_input/3, name, options)
  end

  def textarea_field(f, name, options \\ []) do
    field(f, &textarea/3, name, options)
  end

  def datetime_select_field(f, name, options \\ []) do
    field(f, &datetime_select/3, name, options)
  end

  def date_select_field(f, name, options \\ []) do
    field(f, &date_select/3, name, options)
  end

  def number_input_field(f, name, options \\ []) do
    field(f, &number_input/3, name, options)
  end

  def checkbox_field(f, name, options \\ []) do
    field(f, &checkbox/3, name, options)
  end

  def select_field(form, name, select_options, options \\ []) do
    # TODO: Warn! Code duplication due to select being /4 and not /3 function
    # FIXME
    klass = "field"
    {klass, error_tag} = if error = form.errors[name] do
      {
        "#{klass} field-with-errors",
        content_tag(:span, translate_error(error), class: "field-error")
      }
    else
      {klass, nil}
    end

    content_tag :div, class: klass do
      [(select(form, name, select_options, options)), error_tag] |> Enum.filter(&(&1))
    end
  end
end
