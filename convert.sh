#!/usr/bin/env bash

# Author: Zhang Huangbin <zhb _at_ iredmail.org>
# Purpose: Convert markdown articles to HTML files.

# Directory used to store converted html files.
PWD="."
SOURCE_DIR="${PWD}/src"
OUTPUT_DIR="${PWD}/html"
INDEX_MD="${OUTPUT_DIR}/index.md"
README_MD="${PWD}/README.md"

# Pack all converted HTML files for downloading
PACK_NAME="iredmail-docs"
PACK_TAR_NAME="iredmail-docs.tar.bz2"

[ -d ${OUTPUT_DIR} ] || mkdir -p ${OUTPUT_DIR}

CONVERTER="${PWD}/tools/markdown2html.py"
CMD_CONVERT="python ${CONVERTER}"
#CMD_CONVERT=":"
CHANGED_FILES="$(hg st)"
TODAY="$(date +%Y-%m-%d)"

strip_name_prefix()
{
    name="${1}"
    name="$(echo ${name/#\.\//})"  # ./filename
    name="$(echo ${name/#[0-9][0-9][0-9]-/})"   # nnn-
    name="$(echo ${name/#[0-9][0-9]-/})"        # nn-
    name="$(echo ${name/#[0-9]-/})"             # n-
    echo "${name}"
}

# Chapter directories in specified order
all_chapter_dirs="installation \
                  upgrade \
                  mua \
                  howto \
                  integrations \
                  cluster \
                  migrations \
                  troubleshooting \
                  faq"

# Get chapter info
#   - title: _title.md
#   - summary: _summary.md
echo "We're migrating [old wiki documents](http://www.iredmail.org/wiki) to Markdown format for easier maintenance, all documents are available [here](https://bitbucket.org/zhb/docs.iredmail.org/src)." > ${INDEX_MD}
echo "We're migrating [old wiki documents](http://www.iredmail.org/wiki) to Markdown format for easier maintenance." > ${README_MD}

for chapter_dir in ${all_chapter_dirs}; do
    # Get articles
    all_chapter_articles="$(find ${chapter_dir} -depth 1 -type f -iname '[0-9a-z]*.md')"

    # Output directory.
    # Remove prefix '[number]-' in chapter directory name.
    #chapter_dir_in_article="$(strip_name_prefix ${chapter_dir})"
    #_output_chapter_dir="${OUTPUT_DIR}/${chapter_dir_in_article}"

    # Get chapter title.
    _title_md="${chapter_dir}/_title.md"
    _summary_md="${chapter_dir}/_summary.md"

    if [ -f ${_title_md} ]; then
        # generate index info of chapter
        _chapter_title="$(cat ${_title_md})"
        echo -e "### ${_chapter_title}" >> ${INDEX_MD}
        echo -e "# ${_chapter_title}" >> ${README_MD}

        if [ -f ${_summary_md} ]; then
            _chapter_summary="$(cat ${_summary_md})"
            echo -e "${_chapter_summary}" >> ${INDEX_MD}
            echo -e "${_chapter_summary}" >> ${README_MD}
        fi
    fi

    # Article info:
    #   - title: first line (without '#') of markdown file
    for article_file in ${all_chapter_articles}; do
        article_file_basename="$(basename ${article_file})"
        article_file_without_prefix_path="$(echo ${article_file/#\.\//})"
        article_file_without_prefix="$(strip_name_prefix ${article_file})"

        article_html_file="$(strip_name_prefix ${article_file_basename})"
        # Replace '.md' suffix by '.html'
        article_html_file="$(echo ${article_html_file/%.md/.html})"

        hide_article_in_index='NO'
        if echo "${article_file_basename}" | grep '^0-' &>/dev/null; then
            hide_article_in_index='YES'
        fi

        # Get title.
        # title format: '# title'
        _article_title="$(head -1 ${article_file} | awk -F'# ' '{print $2}')"
        # title format: '<h1>title</h1>'
        #_article_title="$(head -1 ${article_file} | awk -F'<h1>' '{print $2}' | awk -F'</h1>' '{print $1}')"

        #echo "* [${_article_title}](${chapter_dir_in_article}/${article_html_file})" >> ${INDEX_MD}
        if [ X"${hide_article_in_index}" == X'NO' ]; then
            echo "* [${_article_title}](${article_html_file})" >> ${INDEX_MD}

            # 'src/default/' is path to view source file on bitbucket.org
            echo "* [${_article_title}](https://bitbucket.org/zhb/docs.iredmail.org/src/default/${article_file_without_prefix_path})" >> ${README_MD}
        fi

        # Convert file if it was modified
        echo ${CHANGED_FILES} | grep ${article_file} > /dev/null
        md_changed="$?"

        echo ${CHANGED_FILES} | grep $(basename ${CONVERTER}) > /dev/null
        converter_changed="$?"

        if [ X"${md_changed}" == X'0' -o X"${converter_changed}" == X'0' ]; then
            echo "* Converting: ${article_file}"
            ${CMD_CONVERT} ${article_file} ${OUTPUT_DIR} \
                output_filename="${article_html_file}" \
                title="${_article_title}" \
                add_index_link='yes' \
                add_page_footer='yes'
        fi
    done

    # Append addition links at the chapter bottom on index page.
    _links_md="${chapter_dir}/_links.md"

    if [ -f ${_links_md} ]; then
        cat ${_links_md} >> ${INDEX_MD}
        cat ${_links_md} >> ${README_MD}
    fi
done

#cd ${OUTPUT_DIR}

echo "* Converting ${INDEX_MD} for index page."
${CMD_CONVERT} ${INDEX_MD} ${OUTPUT_DIR} title="iRedMail Documentations"

# Cleanup
rm -f ${INDEX_MD}

if echo "$@" | grep -q -- '--pack'; then
    echo "* Pack all HTML files: ${PACK_TAR_NAME}"

    cd ${PWD}
    pack_dir="${PACK_NAME}-${TODAY}"
    mkdir -p ${pack_dir}
    cp -rf html/* ${pack_dir}
    tar cjf ${PACK_TAR_NAME} ${pack_dir}
    rm -rf ${pack_dir}
fi

# Sync newly generated HTML files to local diretories.
if echo "$@" | grep -q -- '--sync-local'; then
    # Copy to local hg repo of http://www.iredmail.org/docs/
    echo "* Syncing converted HTML files."
    rm -rf ../web/docs/*
    cp -rf html/* ../web/docs/

    if [ -f ${PACK_TAR_NAME} ]; then
        cp ${PACK_TAR_NAME} ../web/docs/
    fi

    # Copy to iredmail.com/docs/
    rm -rf /Volumes/STORAGE/Dropbox/Backup/iredmail.com/docs/*
    cp -rf html/* /Volumes/STORAGE/Dropbox/Backup/iredmail.com/docs/
    if [ -f ${PACK_TAR_NAME} ]; then
        cp -f ${PACK_TAR_NAME} /Volumes/STORAGE/Dropbox/Backup/iredmail.com/docs/
    fi

    rm -f ${PACK_TAR_NAME}
fi
