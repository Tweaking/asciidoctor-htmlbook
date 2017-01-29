require 'test_helper'

class Asciidoctor::Htmlbook::Converter::QuoteTest < ConverterTest
  def test_convert_quote
    doc = <<~EOF
      ____
      Quote content.
      ____
    EOF

    html = <<~EOF
      <blockquote>
        <p>Quote content.</p>
      </blockquote>
    EOF

    assert_convert_equal html, doc
  end

  def test_convert_quote_with_attribution_and_citetitle
    doc = <<~EOF
      [quote, attribution, citetitle]
      ____
      Quote content.
      ____
    EOF

    html = <<~EOF
      <blockquote>
        <p>Quote content.</p>
        <p data-type="attribution">attribution</p>
        <p data-type="citetitle">citetitle</p>
      </blockquote>
    EOF

    assert_convert_equal html, doc
  end
end