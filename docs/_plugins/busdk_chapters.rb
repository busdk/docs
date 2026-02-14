# frozen_string_literal: true

# Wraps each h2 and its following siblings (until the next h2 or .busdk-prev-next)
# in a <section class="busdk-chapter"> so CSS can style alternating chapter backgrounds.
# Use in layout: {{ content | wrap_busdk_chapters }}

require "nokogiri"

module Jekyll
  module BusdkChaptersFilter
    def wrap_busdk_chapters(html)
      return html if html.nil? || html.to_s.strip.empty?

      fragment = Nokogiri::HTML::DocumentFragment.parse(html.to_s)
      nodes = fragment.children.to_a
      output = []
      i = 0

      while i < nodes.size
        node = nodes[i]
        unless node.element?
          output << node
          i += 1
          next
        end

        if node.name == "h2"
          section = Nokogiri::XML::Node.new("section", fragment.document)
          section["class"] = "busdk-chapter"
          section.add_child(node)
          i += 1
          while i < nodes.size
            n = nodes[i]
            break unless n.element?
            break if n.name == "h2"
            break if n["class"].to_s.include?("busdk-prev-next")

            section.add_child(n)
            i += 1
          end
          output << section
        else
          output << node
          i += 1
        end
      end

      fragment.children.each(&:remove)
      output.each { |n| fragment.add_child(n) }
      fragment.to_html
    end
  end
end

Liquid::Template.register_filter(Jekyll::BusdkChaptersFilter)
