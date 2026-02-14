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
            # Include non-elements (e.g. text/whitespace) in the section; only stop at section boundaries.
            if n.element?
              l = heading_level(n)
              break if l && l <= level
              break if level == 2 && n["class"].to_s.include?("busdk-prev-next")
            end
            section.add_child(n)
            i += 1
          end
          section_children = section.children.to_a
          section.children.each(&:remove)
          grouped = group_by_heading(section_children, level + 1, document)
          # Top-level chapters use a full-width chapter-inner. Non-section content is grouped into
          # .busdk-content-inner blocks, while level-3 chapter sections stay full-width.
          if level == 2
            inner = Nokogiri::XML::Node.new("div", document)
            inner["class"] = "busdk-chapter-inner"
            content_block = Nokogiri::XML::Node.new("div", document)
            content_block["class"] = "busdk-chapter-section-inner busdk-content-inner"
            flush_content_block = lambda do
              next if content_block.children.empty?
              content_section = Nokogiri::XML::Node.new("section", document)
              content_section["class"] = "busdk-chapter busdk-chapter--level-3 busdk-chapter--title"
              content_section.add_child(content_block)
              inner.add_child(content_section)
              content_block = Nokogiri::XML::Node.new("div", document)
              content_block["class"] = "busdk-chapter-section-inner busdk-content-inner"
            end
            grouped.each do |c|
              if c.element? && c.name == "section" && c["class"].to_s.include?("busdk-chapter--level-3")
                flush_content_block.call
                inner.add_child(c)
              else
                content_block.add_child(c)
              end
            end
            flush_content_block.call
            section.add_child(inner)
          elsif level == 3
            section_inner = Nokogiri::XML::Node.new("div", document)
            section_inner["class"] = "busdk-chapter-section-inner busdk-content-inner"
            grouped.each { |c| section_inner.add_child(c) }
            section.add_child(section_inner)
          else
            grouped.each { |c| section.add_child(c) }
          end
          output << section
        else
          # Wrap .busdk-prev-next in a full-width bar with content-inner so background spans the page.
          if node.element? && node["class"].to_s.include?("busdk-prev-next")
            bar = Nokogiri::XML::Node.new("div", document)
            bar["class"] = "busdk-prev-next-bar"
            inner = Nokogiri::XML::Node.new("div", document)
            inner["class"] = "busdk-content-inner"
            inner.add_child(node)
            bar.add_child(inner)
            output << bar
            i += 1
          elsif level == 2 && node.element? && node.name == "h3" && %w[sources document-control].include?(node["id"].to_s)
            # Wrap Sources and Document control (and any following meta h3s) in .busdk-meta-block > .busdk-meta-section for card layout.
            wrapper = Nokogiri::XML::Node.new("div", document)
            wrapper["class"] = "busdk-meta-block busdk-content-inner"
            loop do
              section_div = Nokogiri::XML::Node.new("div", document)
              section_div["class"] = "busdk-meta-section"
              section_div.add_child(node)
              i += 1
              while i < nodes.size
                n = nodes[i]
                l = heading_level(n)
                break if n.element? && l && l <= 3
                section_div.add_child(n)
                i += 1
              end
              wrapper.add_child(section_div)
              break if i >= nodes.size
              node = nodes[i]
              break unless node.element? && node.name == "h3" && %w[sources document-control].include?(node["id"].to_s)
            end
            output << wrapper
            # i already advanced; do not increment again
          else
            output << node
            i += 1
          end
        end
      end

      output
    end
  end
end

Liquid::Template.register_filter(Jekyll::BusdkChaptersFilter)
