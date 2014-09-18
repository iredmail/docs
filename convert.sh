#!/usr/bin/env bash

# Author: Zhang Huangbin <zhb _at_ iredmail.org>
# Purpose: Convert markdown articles to HTML files.

# TODO
#   - describe the directory structure and how it works
#   - remove '1-', '2-' in html file name
#   - incorrect CSS path in article html file
#   - better way to strip prefix in dir/file name: [number]- 

# Directory used to store converted html files.
PWD="."
SOURCE_DIR="${PWD}/src"
OUTPUT_DIR="${PWD}/html"
INDEX_MD="${OUTPUT_DIR}/index.md"
README_MD="${PWD}/README.md"

[ -d ${OUTPUT_DIR} ] || mkdir -p ${OUTPUT_DIR}

CMD_CONVERT="python ${PWD}/tools/markdown2html.py"
#CMD_CONVERT=":"

strip_name_prefix()
{
    name="${1}"
    name="$(echo ${name/#\.\//})"  # ./filename
    name="$(echo ${name/#[0-9][0-9][0-9]-/})"   # nnn-
    name="$(echo ${name/#[0-9][0-9]-/})"        # nn-
    name="$(echo ${name/#[0-9]-/})"             # n-
    echo "${name}"
}

# Get directories of chapters
all_chapter_dirs="$(find . -d 1 -type d -iname '[0-9]*' | sort)"
#echo "* Found chapters:"
#for dl in ${all_chapter_dirs}; do
#    echo "  - $dl"
#done

# Get chapter info
#   - title: _title.md
#   - summary: _summary.md
echo '' > ${INDEX_MD}
echo '' > ${README_MD}
for chapter_dir in ${all_chapter_dirs}; do
    # Get articles
    all_chapter_articles="$(find ${chapter_dir} -depth 1 -type f -iname '[0-9a-z]*.md')"

    echo "* ${chapter_dir} articles:"
    for article in ${all_chapter_articles}; do
        echo "  - ${article}"
    done

    # Output directory.
    # Remove prefix '[number]-' in chapter directory name.
    chapter_dir_in_article="$(strip_name_prefix ${chapter_dir})"
    _output_chapter_dir="${OUTPUT_DIR}/${chapter_dir_in_article}"

    _title_md="${chapter_dir}/_title.md"
    _summary_md="${chapter_dir}/_summary.md"

    if [ -f ${_title_md} ]; then
        # generate index info of chapter
        _chapter_title="$(cat ${_title_md})"
        echo -e "\n# ${_chapter_title}\n" >> ${INDEX_MD}
        echo -e "\n# ${_chapter_title}\n" >> ${README_MD}

        if [ -f ${_summary_md} ]; then
            echo -e "\n\n$(cat ${_title_md})\n\n" >> ${INDEX_MD}
            echo -e "\n\n$(cat ${_title_md})\n\n" >> ${README_MD}
        fi
    fi

    mkdir -p ${_output_chapter_dir} &>/dev/null

    # Create ${_output_chapter_dir}/_summary.html
    if [ -f ${_summary_md} ]; then
        ${CMD_CONVERT} ${_summary_md} ${_output_chapter_dir}
    fi

    # Article info:
    #   - title: first line (without '#') of markdown file
    for article_file in ${all_chapter_articles}; do
        article_file_basename="$(basename ${article_file})"
        article_html_file="$(strip_name_prefix ${article_file_basename})"

        # Replace '.md' suffix by '.html'
        article_html_file="$(echo ${article_html_file/%.md/.html})"

        # Get title.
        _article_title="$(head -1 ${article_file} | awk -F'#' '{print $2}')"
        #echo "article title: ${_article_title}"
        echo "* [${_article_title}](${chapter_dir_in_article}/${article_html_file})" >> ${INDEX_MD}
        echo "* [${_article_title}](${chapter_dir}/${article_file})" >> ${README_MD}

        ${CMD_CONVERT} ${article_file} ${_output_chapter_dir} title="${_article_title}"
    done
done

#cd ${OUTPUT_DIR}

# Generate index.html
${CMD_CONVERT} ${INDEX_MD} ${OUTPUT_DIR} css='./css/markdown.css' title="iRedMail Documentations"

# Cleanup
rm -f ${INDEX_MD}
