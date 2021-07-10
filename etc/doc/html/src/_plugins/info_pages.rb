require 'kramdown'
require 'fileutils'

module SonicPiDocPlugin
  # Subclass of `Jekyll::Page` with custom method definitions.
  class PageWithCustomDestination < Jekyll::Page
    def initialize(site, base, dir, name, destination)
      @destination = destination
      #puts destination
      super(site, base, dir, name)
    end

    def destination(*)
      return @destination
    end

    # def read_yaml(src_path, opts={})
    #   begin
    #     puts input
    #     self.content = File.read(src_path, **Utils.merged_file_read_opts(site, opts))
    #     if input =~ Jekyll::Document::YAML_FRONT_MATTER_REGEXP
    #       self.content = Regexp.last_match.post_match
    #       self.data = SafeYAML.load(Regexp.last_match(1))
    #     end
    #   rescue Psych::SyntaxError => e
    #     Jekyll.logger.warn "YAML Exception reading #{self.name}: #{e.message}"
    #     raise e if site.config["strict_front_matter"]
    #   rescue StandardError => e
    #     Jekyll.logger.warn "Error reading file #{self.name}: #{e.message}"
    #     raise e if site.config["strict_front_matter"]
    #   end
    #
    #   self.data ||= {}
    #
    #   validate_data! self.name
    #   validate_permalink! self.name
    #
    #   self.data
    # end
  end

  class TOCInclude < Jekyll::Inclusion
    def initialize(site, base, name, content)
      @site = site
      @name = name
      @path = Jekyll::PathManager.join(base, name)
      @content = content
    end
  end

  class TOCGenerator < Jekyll::Generator
    safe true

    def generate(site)
      generate_toc(site)
      generate_info_pages(site)
    end

    def generate_toc(site)
      puts "Generating tables of contents..."
      site.data["toc"].each do |lang, toc_data|
        puts(lang)
        generated_toc = "<div class=\"toc\">\n"

        toc_data.each { |section, section_data|
          #puts(section)
          generated_toc << "<div id=\"#{section}\" class=\"tabcontent section_toc #{section}\">\n"
          generated_toc << "<ul class=\"section_toc_list\">\n"
          section_data["pages"].each { |page|
            generated_toc << "<li>"
            generated_toc << "<a href=\"#{File.join(site.config["url"], site.config["baseurl"], page["url"])}\">#{page["name"].gsub(/"/, '&quot;')}</a>"
            generated_toc << "</li>"
            #puts(page)
            if (page.key?("subpages"))
              if (page["subpages"].length > 0)
                generated_toc << "<ul class=\"toc_list\">\n"
                page["subpages"].each { |subpage|
                  generated_toc << "<li>"
                  generated_toc << "<a href=\"#{File.join(site.config["url"], site.config["baseurl"], subpage["url"])}\">#{subpage["name"].gsub(/"/, '&quot;')}</a>"
                  generated_toc << "</li>"
                }
                generated_toc << "</ul>\n"
              end
            end
          }
          generated_toc << "</ul>\n"
          generated_toc << "</div>\n"
        }
        generated_toc << "</ul>\n"
        generated_toc << "</div>\n"

        site.inclusions["toc_#{lang}.html"] = TOCInclude.new(site, File.join(site.source, "_include"), "toc_#{lang}.html", generated_toc)
      end
      puts "Done!"
    end

    def generate_info_pages(site)
      puts "Generating info pages..."
      info_pages = []
      info_files = []

      site.pages.each do |page|
        if (page.dir == "/info/")
          info_pages << page
        end
      end

      site.static_files.each do |page|
        if (page.relative_path.include?("/info/"))
          info_files << page
        end
      end

      info_pages.each do |page|
        #puts page.name
        site.data["languages"].each do |lang, lang_name|
          file_path = "#{site.dest}/#{lang}/info/#{page.basename}.html"
          #content = ""
          #if (page.ext == ".md")
          #  content = Kramdown::Document.new(page.content).to_html.gsub(/\n/, "")
          #else
          #  content = page.content
          #end
          #print content
          new_page = PageWithCustomDestination.new(site, site.source, page.dir, page.name, file_path)
          new_page.data.merge!("lang" => lang)
          site.pages << new_page
        end
        site.pages.delete(page)
      end

      info_files.each do |file|
        src_file = File.join(site.source, file.relative_path)

        File.open(src_file, 'r:UTF-8') do |src|
          content = src.read
          site.data["languages"].each do |lang, lang_name|
            dest_file = File.join(site.dest, lang, file.relative_path)

            if (FileUtils.uptodate?(dest_file, src_file) == false)
              if (Dir.exist?(File.dirname(dest_file)) == false)
                FileUtils.mkdir_p(File.dirname(dest_file))
              end

              File.open(dest_file, 'w') do |out|
                out << content
              end
            end

          end

        end
        site.static_files.delete(file)
      end
      puts "Done!"
    end

  end

end
