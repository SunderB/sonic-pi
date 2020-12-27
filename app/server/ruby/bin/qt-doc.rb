#!/usr/bin/env ruby
#--
# This file is part of Sonic Pi: http://sonic-pi.net
# Full project source: https://github.com/samaaron/sonic-pi
# License: https://github.com/samaaron/sonic-pi/blob/main/LICENSE.md
#
# Copyright 2013, 2014, 2015, 2016 by Sam Aaron (http://sam.aaron.name).
# All rights reserved.
#
# Permission is granted for use, copying, modification, and
# distribution of modified versions of this work as long as this
# notice is included.
#++

require 'cgi'
require 'optparse'
require 'fileutils'

require_relative "../core.rb"
require_relative "../lib/sonicpi/synths/synthinfo"
require_relative "../lib/sonicpi/util"
require_relative "../lib/sonicpi/runtime"
require_relative "../lib/sonicpi/lang/core"
require_relative "../lib/sonicpi/lang/sound"
require_relative "../lib/sonicpi/lang/minecraftpi"
require_relative "../lib/sonicpi/lang/midi"

require 'active_support/inflector'


include SonicPi::Util

# Clear all the folders
FileUtils::rm_rf "#{qt_gui_path}/help/"
FileUtils::mkdir "#{qt_gui_path}/help/"

FileUtils::rm_rf "#{qt_gui_path}/info/"
FileUtils::mkdir "#{qt_gui_path}/info/"

FileUtils::rm_rf "#{qt_gui_path}/book/"
FileUtils::mkdir "#{qt_gui_path}/book/"

# Copy images for tutorial
FileUtils::cp_r("#{etc_path}/doc/images", "#{qt_gui_path}/help/")

# List of all languages with GUI translation files
# Commented out languages currently have no translated strings
@lang_names = Hash[
  "bg" => "български", # Bulgarian
  #"bn" => "বাংলা", # Bengali/Bangla
  "bs" => "Bosanski/босански", # Bosnian
  "ca" => "Català", # Catalan
  #"ca@valencia" => "Valencià", # Valencian
  "cs" => "Čeština", # Czech
  "da" => "Dansk", # Danish
  "de" => "Deutsch", # German
  "el" => "ελληνικά", # Greek
  #"en-AU" => "English (Australian)", # English (Australian)
  "en-GB" => "English (UK)", # English (UK) - default language
  "en-US" => "English (US)", # English (US)
  #"eo" => "Esperanto", # Esperanto
  "es" => "Español", # Spanish
  "et" => "Eesti keel", # Estonian
  "fa" => "فارسی", # Persian
  "fi" => "Suomi", # Finnish
  "fr" => "Français", # French
  "ga" => "Gaeilge", # Irish
  "gl" => "Galego", # Galician
  "he" => "עברית", # Hebrew
  "hi" => "हिन्दी", # Hindi
  "hu" => "Magyar", # Hungarian
  "hy" => "Հայերեն", # Armenian
  "id" => "Bahasa Indonesia", # Indonesian
  "is" => "Íslenska", # Icelandic
  "it" => "Italiano", # Italian
  "ja" => "日本語/にほんご", # Japanese
  "ka" => "ქართული", # Georgian
  "ko" => "한국어", # Korean
  "nb" => "Norsk Bokmål", # Norwegian Bokmål
  "nl" => "Nederlands", # Dutch (Netherlands)
  "pl" => "Polski", # Polish
  "pt" => "Português", # Portuguese
  "pt-BR" => "Português do Brasil", # Brazilian Portuguese
  "ro" => "Română", # Romanian
  "ru" => "Pусский", # Russian
  "si" => "සිංහල", # Sinhala/Sinhalese
  "sk" => "Slovenčina/Slovenský Jazyk", # Slovak/Slovakian
  "sl" => "Slovenščina/Slovenski Jezik", # Slovenian
  "sv" => "Svenska", # Swedish
  "sw" => "Kiswahili", # Swahili
  "ti" => "ไทย", # Thai
  "tr" => "Türkçe", # Turkish
  "ug" => "ئۇيغۇر تىلى", # Uyghur
  "uk" => "Українська", # Ukranian
  "vi" => "Tiếng Việt", # Vietnamese
  "zh" => "繁體中文", # Mandarin Chinese (Traditional)
  "zh-Hans" => "简体中文", # Mandarin Chinese (Simplified)
  "zh-Hk" => "廣東話", # Cantonese
  "zh-TW" => "臺灣華語" # Taiwanese Mandarin
]

#docs = []
@filenames = []
@count = 0

@options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: qt-doc.rb [options]"

  opts.on('-o', '--output NAME', 'Output filename') { |v| @options[:output_name] = v }

end.parse!


# Create the tab entry and the html pages for a section of the documentation
#
# ==== Attributes
#
# * +name+ - the name of the tab; valid names: lang, synths, fx, samples, examples
# * +doc_items+ - a hash of all the html pages of the tab; the keys are used as
#                 the filenames of the individual generated help files
# * +titles+ - a hash of titles of the pages; if nil, then the keys of doc_items will be used for the titles
# * +titleize+ - Whether to titleize the title or not
# * +should_sort+ - whether to sort the pages by name
# * +with_keyword+
# * +page_break+
# * +chapters+
# * +lang+ - the language of the tab
#
# ====
# HTML files for all the pages are generated in "app/gui/qt/help/#{name}/#{lang}/"
# The HTML book file is generated at "app/gui/qt/book/Sonic Pi - #{name} (#{lang}).html"
#
# Returns the map of the titles to the keywords and file names to be used in ruby_help.h
#
def make_doc_tab(name, doc_items, titles=nil, titleize=false, should_sort=true, with_keyword=false, page_break=false, chapters=false, lang="en")
  return if doc_items.empty?

  puts("#{name} #{lang}")

  FileUtils::rm_rf "#{qt_gui_path}/help/#{name}/#{lang}/"
  FileUtils::mkdir_p "#{qt_gui_path}/help/#{name}/#{lang}/"

  list_widget = "#{name}NameList"
  layout = "#{name}Layout"
  tab_widget = "#{name}TabWidget"
  help_pages = "#{name}HelpPages"

  docs = "  // #{name} info\n"

  docs << "  struct help_page #{help_pages}[] = {\n"
  doc_items = doc_items.sort if should_sort

  book = ""
  toc = "<ul class=\"toc\">\n"
  toc_level = 0

  # Iterate through each item
  doc_items.each do |n, doc|
    # Make sure the file name is valid
    item_name = n.tr("<>:\"/\\|?*", "_").gsub("([\\s])+", " ").lstrip()
    #item_var = "#{name}_item_#{@count+=1}"
    #item_var = "#{name}_#{item_name}_#{@count+=1}"
    item_var = "#{name}_#{item_name}"

    filename = "help/#{name}/#{lang}/#{item_name}.html"

    if titles
      title = titles[n]
    else
      title = n
    end

    if titleize == :titleize then
      title = ActiveSupport::Inflector.titleize(title)
      # HPF et al get capitalized
      if name == 'fx' and title =~ /pf$/ then
        title = title.upcase
      end
    end

    # Add table of contents listing
    # Check if to go up or down a level
    if title.start_with?("   ") then
      if toc_level == 0 then
        toc << "<ul class=\"toc\">\n"
        toc_level += 1
      end
    else
      if toc_level == 1 then
        toc << "</ul>\n"
        toc_level -= 1
      end
    end
    toc << "<li><a href=\"\##{item_var}\">#{title.gsub(/"/, '&quot;')}</a></li>\n"

    docs << "    { "

    # Title
    docs << "QString::fromUtf8(" unless title.ascii_only?
    docs << "\"#{title.gsub(/"/, '\\"')}\""
    docs << ")" unless title.ascii_only?

    docs << ", "

    if with_keyword then
      docs << "\"#{item_name.downcase}\""
    else
      docs << "NULL"
    end

    # resource URL
    docs << ", "
    docs << "QString::fromUtf8(" unless filename.ascii_only?
    docs << "\"qrc:///#{filename}\""
    docs << ")" unless filename.ascii_only?
    docs << "},\n"

    @filenames << filename

    # Write the html file
    File.open("#{qt_gui_path}/#{filename}", 'w') do |f|
      f << "#{doc}"
    end

    if chapters then
      c = title[/\A\s*[0-9]+(\.[0-9]+)?/]
      doc.gsub!(/(<h1.*?>)/, "\\1#{c} - ")
    end
    if page_break then
      doc.gsub!(/<h1.*?>/, "<h1 id=\"#{item_var}\" style=\"page-break-before: always;\">")
    else
      doc.gsub!(/<h1.*?>/, "<h1 id=\"#{item_var}\">")
    end
    book << doc
    book << "<hr/>\n"
  end

  while toc_level >= 0 do
    toc << "</ul>\n"
    toc_level -= 1
  end

  # Add beginning of the book
  book_body = book[/<body.*?>/]
  book.gsub!(/<\/?body.*?>/, '')
  book.gsub!(/<meta http-equiv.*?>/, '')
  File.open("#{qt_gui_path}/book/Sonic Pi - #{name.capitalize}" + (lang != "en" ? " (#{lang})" : "") + ".html", 'w') do |f|
    f << "<link rel=\"stylesheet\" href=\"../theme/light/doc-styles.css\" type=\"text/css\"/>\n"
    f << "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"/>\n\n"
    f << book_body << "\n"
    f << toc << "\n"
    f << book << "\n"
    f << "</body>\n"
  end

  docs << "  };\n\n"
  docs << "  addHelpPage(createHelpTab(tr(\"#{name.capitalize}\")), #{help_pages}, #{doc_items.length});\n\n"

  return docs
end

def make_tutorial(lang)
  docs = "// Tutorial - language #{lang}\n"
  tutorial_html_map = {}
  tutorial_titles = {}

  if lang == "en" then
    markdown_path = tutorial_path
  else
    markdown_path = File.expand_path("../generated/#{lang}/tutorial", tutorial_path)
  end
  Dir["#{markdown_path}/*.md"].sort.each do |path|
    f = File.open(path, 'r:UTF-8')
    name = File.basename(path, ".md") #.delete_prefix("0")

    # read first line (title) of the markdown, use as title
    title = f.readline.strip
    # indent subchapters
    title = "   #{title}" if title.match(/\A[A-Z0-9]+\.[0-9]+ /)

    # read remaining content of markdown
    markdown = f.read
    html = SonicPi::MarkdownConverter.convert markdown

    tutorial_html_map[name] = html
    tutorial_titles[name] = title
  end

  docs << make_doc_tab("tutorial", tutorial_html_map, tutorial_titles, false, false, false, true, true, lang)
  return docs
end

def generate_all_tutorials
  docs = "void MainWindow::addTutorialDocsTab(QString lang) {\n"
  tutorial_languages =
    Dir[File.expand_path("../lang/sonic-pi-tutorial-*.po", tutorial_path)].
    map { |p| File.basename(p).gsub(/sonic-pi-tutorial-(.*?).po/, '\1') }
  # docs << "\n  QString systemLocale = QLocale::system().name();\n\n" unless tutorial_languages.empty?

  # Remove English for now
  #tutorial_languages.delete("en")

  # this will sort locale code names by reverse length
  # to make sure that a more specific locale is handled
  # before the generic language code,
  # e.g., "de_CH" should be handled before "de"
  tutorial_languages = tutorial_languages.sort_by! {|n| -n.length}

  # first, try to match all non-default languages (those that aren't "en")
  tutorial_languages.each do |lang|
    docs << "if (lang.startsWith(\"#{lang}\")) {\n"
    docs << make_tutorial(lang)
    docs << "} else "
  end

  # finally, add the default language ("en")
  docs << "{\n" unless (tutorial_languages.empty?)
  docs << make_tutorial("en")
  docs << "}\n" unless (tutorial_languages.empty?)

  docs << "}\n"
  return docs
end

def generate_lang_docs
  ruby_html_map = {
  #  "n.times" => "Loop n times",
  #  "loop" => "Loop forever",
  }

  docs = "void MainWindow::addLangDocsTab() {\n"
  docs << make_doc_tab("lang", SonicPi::Lang::Core.docs_html_map.merge(SonicPi::Lang::Sound.docs_html_map).merge(ruby_html_map), nil, false, true, true, false)
  docs << "}\n"
  return docs
end

def generate_synth_docs
  docs = "void MainWindow::addSynthDocsTab() {\n"
  docs << make_doc_tab("synths", SonicPi::Synths::SynthInfo.synth_doc_html_map, nil, :titleize, true, true, true)
  docs << "}\n"
  return docs
end

def generate_fx_docs
  docs = "void MainWindow::addFXDocsTab() {\n"
  docs << make_doc_tab("fx", SonicPi::Synths::SynthInfo.fx_doc_html_map, nil, :titleize, true, true, true)
  docs << "}\n"
  return docs
end

def generate_sample_docs
  docs = "void MainWindow::addSampleDocsTab() {\n"
  make_doc_tab("samples", SonicPi::Synths::SynthInfo.samples_doc_html_map, nil, false, true, false, true)
  docs << "}\n"
  return docs
end

def generate_examples
  example_html_map = {}
  example_dirs = ["Apprentice", "Illusionist", "Magician", "Sorcerer", "Wizard", "Algomancer"]
  example_dirs.each do |ex_dir|
    Dir["#{examples_path}/#{ex_dir.downcase}/*.rb"].each do |path|
      bname = File.basename(path, ".rb")
      bname = ActiveSupport::Inflector.titleize(bname)
      name = "[#{ex_dir}] #{bname}"
      lines = IO.readlines(path).map(&:chop).map{|s| CGI.escapeHTML(s)}
      html = "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"/>\n\n"
      html << "<body class=\"example\">\n"
      html << '<h1>'
      html << "# #{bname}"
      html << '</h1>'
      html << "<p><pre><code>\n"

      html << "#{lines.join("\n")}\n\n</code></pre></p>\n"
      html << "</body>\n"
      example_html_map[name] = html
    end
  end

  docs = "void MainWindow::addExamplesDocsTab() {\n"
  docs << make_doc_tab("examples", example_html_map, nil, false, false, false, true)
  docs << "}\n"
  return docs
end

def generate_autocomplete
  docs = "void MainWindow::addAutocompleteArgs() {\n"
  docs << "  // FX & Synth arguments for autocompletion\n"
  docs << "  QStringList fxtmp;\n"
  SonicPi::Synths::SynthInfo.get_all.each do |k, v|
    next unless v.is_a? SonicPi::Synths::FXInfo
    next if (k.to_s.include? 'replace_')
    safe_k = k.to_s[3..-1]
    docs << "  // fx :#{safe_k}\n"
    docs << "  fxtmp.clear(); fxtmp "
    v.arg_info.each do |ak, av|
      docs << "<< \"#{ak}:\" ";
    end
    docs << ";\n"
    docs << "  autocomplete->addFXArgs(\":#{safe_k}\", fxtmp);\n"
  end

  docs << "\n\n"

  SonicPi::Synths::SynthInfo.get_all.each do |k, v|
    next unless v.is_a? SonicPi::Synths::SynthInfo
    docs << "  // synth :#{k}\n"
    docs << "  fxtmp.clear(); fxtmp "
    v.arg_info.each do |ak, av|
      docs << "<< \"#{ak}:\" ";
    end
    docs << ";\n"
    docs << "  autocomplete->addSynthArgs(\":#{k}\", fxtmp);\n"
  end
  docs << "}\n"

  return docs
end

def generate_ui_lang_names
  # Make a function to define the locale list map -----
  ui_languages = @lang_names.keys
  ui_languages = ui_languages.sort_by {|l| l.downcase}
  locale_arrays = []
  locale_arrays << "void SettingsWidget::defineLocaleLists() {\n"
  locale_arrays << "availableLocales = {\n"
  # Add each language
  locale_arrays << "{0, \"system_locale\"}"
  i = 1
  ui_languages.each do |lang|
    locale_arrays << ",\n"
    locale_arrays << "{#{i.to_s}, \"#{lang}\"}"
    i += 1
  end
  # End the map
  locale_arrays << "\n};\n"

  # Create a map of the locales to their indices in availableLocales, called localeIndex
  locale_arrays << "localeIndex = {\n"
  # Add each language
  locale_arrays << "{\"system_locale\", 0}"
  i = 1
  ui_languages.each do |lang|
    locale_arrays << ",\n"
    locale_arrays << "{\"#{lang}\", #{i.to_s}}"
    i += 1
  end
  # End the map
  locale_arrays << "\n};\n"

  # Create a map of the locales to their native names, called localeNames
  locale_arrays << "localeNames = {\n"
  # Add each language
  locale_arrays << "{\"system_locale\", \"\"}"
  ui_languages.each do |lang|
    locale_arrays << ",\n"
    locale_arrays << "{\"#{lang}\", \"#{@lang_names[lang]}\"}"
  end
  # End the map
  locale_arrays << "\n};\n"

  # End the function
  locale_arrays << "};\n"

  content = File.readlines("#{qt_gui_path}/utils/lang_list.tmpl")
  lang_names_generated = content.take_while { |line| !line.start_with?("// AUTO-GENERATED")}
  lang_names_generated << "// AUTO-GENERATED HEADER FILE\n"
  lang_names_generated << "// Do not add any code to this file\n"
  lang_names_generated << "// as it will be removed/overwritten\n"
  lang_names_generated << "\n"
  lang_names_generated << "#ifndef LANG_LIST_H\n"
  lang_names_generated << "#define LANG_LIST_H\n"
  lang_names_generated << "#include <map>\n"
  lang_names_generated << locale_arrays.join()
  lang_names_generated << "#endif\n"

  File.open("#{qt_gui_path}/utils/lang_list.h", 'w') do |f|
    f << lang_names_generated.join()
  end
end


# update ruby_help.h
if @options[:output_name] then
   cpp = @options[:output_name]
else
   cpp = "#{qt_gui_path}/utils/ruby_help.h"
end

content = File.readlines("#{qt_gui_path}/utils/ruby_help.tmpl")
new_content = content.take_while { |line| !line.start_with?("// AUTO-GENERATED-DOCS")}
new_content << "// AUTO-GENERATED-DOCS\n"
new_content << "// Do not manually add any code to this file\n"
new_content << "// otherwise it will be removed\n"
new_content << "\n"
new_content << "#ifndef RUBY_HELP_H\n"
new_content << "#define RUBY_HELP_H\n"
new_content << generate_all_tutorials()
new_content << generate_synth_docs()
new_content << generate_fx_docs()
new_content << generate_sample_docs()
new_content << generate_lang_docs()
new_content << generate_examples()
new_content << generate_autocomplete()
new_content << "\n\n"
new_content << "void MainWindow::initDocsWindow(QString lang) {
  addTutorialDocsTab(lang);
  addSynthDocsTab();
  addFXDocsTab();
  addSampleDocsTab();
  addLangDocsTab();
  addExamplesDocsTab();
  addAutocompleteArgs();
}\n"
new_content << "\n"
new_content << "#endif\n"


File.open(cpp, 'w') do |f|
  f << new_content.join
end

File.open("#{qt_gui_path}/help_files.qrc", 'w') do |f|
  f << "<RCC>\n  <qresource prefix=\"/\">\n"
  f << @filenames.map{|n| "    <file>#{n}</file>\n"}.join
  f << "  </qresource>\n</RCC>\n"
end


###
# Generate info pages
###

info_sources = ["CHANGELOG.md", "CONTRIBUTORS.md", "COMMUNITY.md", "CORETEAM.html", "LICENSE.md"]
outputdir = "#{qt_gui_path}/info"

info_sources.each do |src|

  input_path = "#{root_path}/#{src}"
  base = File.basename(input_path)
  m = base.match /(.*)\.(.*)/
  bn = m[1]
  ext = m[2]

  input = IO.read(input_path, :encoding => 'utf-8')
  if ext == "md"
    html = SonicPi::MarkdownConverter.convert(input)
  else
    html = SonicPi::MarkdownConverter.massage!(input)
  end

  output_path = "#{outputdir}/#{bn}.html"

  File.open(output_path, 'w') do |f|
    f << html
  end

end

generate_ui_lang_names()
