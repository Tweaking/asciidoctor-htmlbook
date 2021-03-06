module Asciidoctor
  module Htmlbook
    class Converter < Asciidoctor::Converter::Base
      register_for "htmlbook"

      DEFAULT_TEMPLATE_PATH = File.expand_path('../../../../templates', __FILE__)

      def initialize(backend, options = {})
        super
        @template_dirs = (options[:template_dirs] || []).push(DEFAULT_TEMPLATE_PATH)
        @templates = {}
      end

      def convert(node, transform = nil, options = {})
        template = if (node.node_name == 'document' && transform == 'embedded')
          get_template('embedded')
        else
          get_template(node.node_name)
        end

        template.render 'node' => node_to_liquid(node)
      end

      private

      def get_template(name)
        return @templates[name] if @templates[name]

        @template_dirs.each do |template_dir|
          path = File.join template_dir, "#{name}.html"
          if File.exist?(path)
            @templates[name] = Liquid::Template.parse(File.read(path))
            break
          end
        end

        unless @templates[name]
          raise "Template not found #{name}"
        end

        @templates[name]
      end

      def node_to_liquid(node)
        case node
        when Asciidoctor::Document
          document_to_liquid(node)
        when Asciidoctor::Section
          section_to_liquid(node)
        when Asciidoctor::Block
          block_to_liquid(node)
        when Asciidoctor::List
          list_to_liquid(node)
        when Asciidoctor::Table
          table_to_liquid(node)
        when Asciidoctor::Inline
          inline_to_liquid(node)
        else
          raise "Uncatch type #{node} #{node.attributes}"
        end
      end

      def abstract_node_to_liquid(node)
        {
          'context' => node.context.to_s,
          'node_name' => node.node_name,
          'id' => node.id,
          'attributes' => node.attributes,
          'document' => {
            'references' => {
              'ids' => node.document.references[:ids]
            },
            'attributes' => node.document.attributes
          }
        }
      end

      def abstract_block_to_liquid(node)
        abstract_node_to_liquid(node).merge({
          'level' => node.level,
          'title' => node.title,
          'caption' => node.caption,
          'captioned_title' => node.captioned_title,
          'style' => node.style,
          'content' => node.content
        })
      end

      def document_to_liquid(node)
        abstract_block_to_liquid(node).merge({
          'header' => {
            'title' => (node.header && node.header.title)
          }
        })
      end

      def section_to_liquid(node)
        abstract_block_to_liquid(node).merge({
          'index' => node.index,
          'number' => node.number,
          'sectname' => node.sectname,
          'special' => node.special,
          'numbered' => node.numbered,
          'sectnum' => node.sectnum
        })
      end

      def block_to_liquid(node)
        case node.context
        when :toc
          abstract_block_to_liquid(node).merge({
            'blockname' => node.blockname,
            'content' => outline(node.document)
          })
        else
          abstract_block_to_liquid(node).merge({
            'blockname' => node.blockname
          })
        end
      end

      def outline(node)
        result = ""
        if node.sections.any? && node.level < (node.document.attributes['toclevels'] || 2)
          result << "<ol>"
          node.sections.each do |section|
            result << "<li>"
            result << %Q(<a href="##{section.id}">)
            result << "#{section.sectnum} " if section.numbered && section.level < (node.document.attributes['sectnumlevels'] || 3)
            result << section.title
            result << "</a>"
            result << outline(section)
            result << "</li>"
          end
          result << "</ol>"
        end
        result
      end

      def list_to_liquid(node)
        case node.context
        when :dlist
          abstract_block_to_liquid(node).merge({
            'items' => node.items.map { |terms, item|
              {
                'terms' => terms.map {|term| listitem_to_liquid(term) },
                'description' => listitem_to_liquid(item)
              }
            }
          })
        else
          abstract_block_to_liquid(node).merge({
            'items' => node.blocks.map { |item| listitem_to_liquid(item) }
          })
        end
      end

      def listitem_to_liquid(node)
        abstract_block_to_liquid(node).merge({
          'text' => (node.text? ? node.text : nil)
        })
      end

      def table_to_liquid(node)
        abstract_block_to_liquid(node).merge({
          'columns' => node.columns,
          'rows' => {
            'head' => node.rows.head.map { |row| row.map {|cell| cell_to_liquid(cell) } },
            'body' => node.rows.body.map { |row| row.map {|cell| cell_to_liquid(cell) } },
            'foot' => node.rows.foot.map { |row| row.map {|cell| cell_to_liquid(cell) } }
          }
        })
      end

      def cell_to_liquid(node)
        abstract_node_to_liquid(node).merge({
          'text' => node.text,
          'content' => node.content,
          'style' => node.style,
          'colspan' => node.colspan,
          'rowspan' => node.rowspan
        })
      end

      def inline_to_liquid(node)
        abstract_node_to_liquid(node).merge({
          'text' => node.text,
          'type' => node.type.to_s,
          'target' => node.target
        })
      end
    end
  end
end
