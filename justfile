#! /usr/bin/env just --working-directory . --justfile

date := `date -u +"%Y-%m"`

version := env_var_or_default("VERSION", "version")
email := env_var_or_default("EMAIL", "email")
name := env_var_or_default("NAME", "name")
phone := env_var_or_default("PHONE", "phone")
github_url := env_var_or_default("GITHUB_URL", "github_url")

root_dir := parent_dir(justfile_dir())

pandoc_css := root_dir + "/resume.css"
pandoc_template_html_embedded := root_dir + '/pandoc-template-html-embedded.html'
pandoc_template_html_standalone := root_dir + '/pandoc-template-html-embedded.html'
pandoc_template_txt := root_dir + '/pandoc-template-txt.txt'
pandoc_lua_filter_txt := root_dir + '/pandoc-lua-filter-txt.lua'

pandoc template infile outfile *ARGS:
  pandoc \
    --from markdown \
    --section-div \
    --shift-heading-level-by=1 \
    -c '{{pandoc_css}}' \
    -V "version={{version}}" \
    -V "email={{email}}" \
    -V "phone={{phone}}" \
    -V "name={{name}}" \
    -V "build-date={{date}}" \
    -V "github-url={{github_url}}" \
    --embed-resources \
    --standalone \
    --metadata "title={{name}}'s Resume" \
    --template '{{template}}' \
    {{ARGS}} \
    '{{infile}}' -o '{{outfile}}'

html markdown template: \
    (
      pandoc
      template
      markdown
      markdown+".html"
    )

txt markdown: \
    (
      pandoc
      pandoc_template_txt
      markdown
      markdown+".txt"
      "--reference-links"
      "--columns 80"
      "--lua-filter" pandoc_lua_filter_txt
    )

html-embedded markdown: (html markdown pandoc_template_html_embedded)
html-standalone markdown: (html markdown pandoc_template_html_standalone)

pdf html:
  html-to-pdf '{{html}}'
