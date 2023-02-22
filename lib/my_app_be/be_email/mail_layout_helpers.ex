defmodule MyAppBe.BeEmail.MailLayoutHelpers do
  @moduledoc false

  use Phoenix.HTML
  import Phoenix.Component

  def mail_button(text, url, opts \\ [])
      when is_binary(url) and is_binary(text) do
    assigns = %{
      text: text,
      url: url,
      color: opts[:color] || "#DD0000",
      textcolor: opts[:textcolor] || "#ffffff",
      align: opts[:align] || "center"
    }

    ~H"""
    <div>
      <!--[if mso]>
      <v:roundrect xmlns:v="urn:schemas-microsoft-com:vml" xmlns:w="urn:schemas-microsoft-com:office:word" href="<%= @url %>" style="height:40px;v-text-anchor:middle;width:300px;" arcsize="10%" stroke="f" fillcolor="<%= @color %>">
        <w:anchorlock/>
        <center style="color:<%= @textcolor %>;font-family:sans-serif;font-size:16px;font-weight:bold;">
          <%= @text %>
        </center>
      </v:roundrect>
      <![endif]-->
      <![if !mso] />
      <table cellspacing="0" cellpadding="0" align={@align}>
        <tr>
          <td
            align="center"
            width="300"
            height="40"
            bgcolor={@color}
            style={
              "-webkit-border-radius: 5px; -moz-border-radius: 5px; border-radius: 5px; color: #{@textcolor}; display: block;"
            }
          >
            <a
              href={@url}
              style="font-size:16px; font-weight: bold; font-family:sans-serif; text-decoration: none; line-height:40px; width:100%; display:inline-block"
            >
              <span style={"color: #{@textcolor};"}>
                <%= @text %>
              </span>
            </a>
          </td>
        </tr>
      </table>
      <![endif] />
    </div>
    """
  end
end
