require "test_helper"

class Asciidoctor::Htmlbook::Converter::InlineCalloutTest < Minitest::Test
  include ConverterTestHelper

  def test_convert_inline_callout
    doc = <<~EOF
      [source,ruby]
      ----
      require "sinatra" <1>

      get "/hi" do <2> <3>
        "Hello World!"
      end
      ----
      <1> Library import
      <2> URL mapping
      <3> Response block
    EOF

    html = <<~EOF
      <figure>
        <pre data-type="programlisting" data-code-language="ruby">require "sinatra" <a data-type="callout" id="callout-CO1-1" href="#colist-CO1-1">1</a>

           get "/hi" do <a data-type="callout" id="callout-CO1-2" href="#colist-CO1-2">2</a> <a data-type="callout" id="callout-CO1-3" href="#colist-CO1-3">3</a>
             "Hello World!"
           end
        </pre>
      </figure>
      <ul data-type="colist">
        <li>
          <a data-type="callout" id="colist-CO1-1" href="#callout-CO1-1">1</a>
        </li>
        <li>
          <a data-type="callout" id="colist-CO1-2" href="#callout-CO1-2">2</a>
        </li>
        <li>
          <a data-type="callout" id="colist-CO1-3" href="#callout-CO1-3">3</a>
        </li>
      </ul>
    EOF

    assert_convert_body html, doc
  end
end
