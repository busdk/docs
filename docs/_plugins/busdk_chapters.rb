# frozen_string_literal: true

# Wraps each heading (h2 through h6) and its content until the next same-or-higher
# heading in a <section class="busdk-chapter busdk-chapter--level-N"> so CSS can
# style alternating chapter backgrounds. Stops before .busdk-prev-next at top level.
# Use in layout: {{ content | wrap_busdk_chapters }}

require "nokogiri"

module Jekyll
  module BusdkChaptersFilter
    def wrap_busdk_chapters(html)
      return html if html.nil? || html.to_s.strip.empty?

      fragment = Nokogiri::HTML::DocumentFragment.parse(html.to_s)
      nodes = fragment.children.to_a
      output = group_by_heading(nodes, 2, fragment.document)
      fragment.children.each(&:remove)
      output.each { |n| fragment.add_child(n) }
      fragment.to_html
    end

    private

    def heading_level(node)
      return nil unless node.element? && node.name.match(/\Ah([2-6])\z/)
      Regexp.last_match(1).to_i
    end

    def group_by_heading(nodes, level, document)
      return nodes if level > 6

      tag = "h#{level}"
      output = []
      i = 0

      while i < nodes.size
        node = nodes[i]
        unless node.element?
          output << node
          i += 1
          next
        end

        if node.name == tag
          section = Nokogiri::XML::Node.new("section", document)
          section["class"] = "busdk-chapter busdk-chapter--level-#{level}"
          section.add_child(node)
          i += 1
          while i < nodes.size
            n = nodes[i]
            break unless n.element?
            l = heading_level(n)
            break if l && l <= level
            break if level == 2 && n["class"].to_s.include?("busdk-prev-next")

            section.add_child(n)
            i += 1
          end
          section_children = section.children.to_a
          section.children.each(&:remove)
          grouped = group_by_heading(section_children, level + 1, document)
          grouped.each { |c| section.add_child(c) }
          output << section
        else
          output << node
          i += 1
        end
      end

      output
    end
  end
end

Liquid::Template.register_filter(Jekyll::BusdkChaptersFilter)
