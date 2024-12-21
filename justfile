#! /usr/bin/env just --working-directory . --justfile

css := "resume.css"
date := `date -u +"%Y-%m"`

version := env_var_or_default("VERSION", "version")
email := env_var_or_default("EMAIL", "email")
name := env_var_or_default("NAME", "name")
phone := env_var_or_default("PHONE", "phone")
github_url := env_var_or_default("GITHUB_URL", "github_url")

html markdown template:
  pandoc \
    --from markdown \
    --section-div \
    --shift-heading-level-by=1 \
    -c '{{css}}' \
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
    '{{markdown}}' -o '{{markdown}}.html'

text markdown:
  pandoc \
    --from markdown \
    --section-div \
    --shift-heading-level-by=1 \
    -c resume.css \
    -V "version={{version}}" \
    -V "email={{email}}" \
    -V "phone={{phone}}" \
    -V "name={{name}}" \
    -V "build-date={{date}}" \
    -V "github-url={{github_url}}" \
    --metadata "title={{name}}'s Resume" \
    --template 'pandoc-template-txt.txt' \
    --embed-resources \
    --standalone \
    --reference-links \
    --columns 80 \
    --lua-filter pandoc-lua-filter-txt.lua \
    --to markdown \
    '{{markdown}}' -o '{{markdown}}.txt'

html-embedded markdown: (html markdown "pandoc-template-html-embedded.html")
html-standalone markdown: (html markdown "pandoc-template-html-standalone.html")

pdf html:
  html-to-pdf '{{html}}'
