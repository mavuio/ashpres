defmodule MyAppWeb.HelperComponents do
  use Phoenix.Component

  # alias MyAppBe.BackendHelpers, as: BH

  def mybutton(assigns) do
    default_classes = "phx-submit-loading: opacity-75 -full inline-flex justify-center
    rounded border border-gray-300 shadow-sm px-4 py-1
    text-base font-medium bg-white text-gray-700 hover:bg-gray-50
    focus:outline-none focus:ring-2 focus:ring-offset-2
    focus:ring-indigo-500 sm:mt-0 sm:-auto sm:text-sm "

    assigns
    |> assign(:class, [default_classes, assigns[:class] || ""])
    |> assign_new(:tabindex, fn -> 0 end)
    |> link()
  end
end
